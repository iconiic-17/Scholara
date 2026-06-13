import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:grantgo/Model/interview_model.dart';
import 'package:grantgo/Services/dio_client.dart';

part 'interview_state.dart';

class InterviewCubit extends Cubit<InterviewState> {
  InterviewCubit() : super(InterviewInitial());

  // ─── Health Check ─────────────────────────────────────────────
  Future<bool> checkHealth() async {
    emit(InterviewHealthChecking());
    try {
      final response = await appDio.get(
        '/interview/health',
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );
      if (response.statusCode == 200) {
        emit(InterviewInitial());
        return true;
      }
      emit(InterviewHealthError('Interview service is unavailable'));
      return false;
    } on DioException catch (e) {
      final msg = _parseError(e);
      emit(InterviewHealthError(msg));
      return false;
    }
  }

  // ─── Start Interview ──────────────────────────────────────────
  Future<void> startInterview({
    required Map<String, dynamic> scholarship,
  }) async {
    emit(InterviewStarting());
    try {
      final response = await appDio.post(
        '/interview/start',
        data: {
          'scholarship': scholarship,
          'recommendations': [{}],
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      emit(
        InterviewInProgress(
          threadId: data['thread_id'],
          question: data['question'],
          questionNumber: data['question_number'],
        ),
      );
    } on DioException catch (e) {
      final msg = _parseError(e);
      final canRetry = msg.contains('waking up') || msg.contains('timed out');
      emit(InterviewError(msg, canRetry: canRetry));
    }
  }

  // ─── Submit Answer ────────────────────────────────────────────
  Future<void> submitAnswer({
    required String threadId,
    required String answer,
    required String currentQuestion,
    required int currentQuestionNumber,
    FeedbackModel? previousFeedback,
  }) async {
    // Keep current state visible while loading
    emit(
      InterviewSubmitting(
        threadId: threadId,
        question: currentQuestion,
        questionNumber: currentQuestionNumber,
        lastFeedback: previousFeedback,
      ),
    );

    try {
      final response = await appDio.post(
        '/interview/answer',
        data: {'thread_id': threadId, 'answer': answer},
        options: Options(
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final bool done = data['done'] ?? false;

      if (done) {
        // Response C — Interview Complete
        final summary = SummaryModel.fromJson(
          data['summary'] as Map<String, dynamic>,
        );
        emit(InterviewComplete(summary: summary));
      } else {
        // Response A or B — Next Question
        final feedback = data['feedback'] != null
            ? FeedbackModel.fromJson(data['feedback'])
            : null;

        emit(
          InterviewInProgress(
            threadId: threadId,
            question: data['question'],
            questionNumber: data['question_number'],
            lastFeedback: feedback,
          ),
        );
      }
    } on DioException catch (e) {
      final msg = _parseError(e);
      // On session expired (404) — inform user, go back to initial
      if (e.response?.statusCode == 404) {
        emit(
          InterviewError(
            'Session expired. Please start a new interview.',
            canRetry: false,
          ),
        );
      } else {
        emit(InterviewError(msg));
      }
    }
  }

  // ─── Reset ────────────────────────────────────────────────────
  void reset() => emit(InterviewInitial());

  // ─── Error Parser ─────────────────────────────────────────────
  String _parseError(DioException e) {
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Request timed out. The AI service may be loading — please try again.';
    }
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] ?? 'Something went wrong';
      }
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection';
    }
    return 'Something went wrong. Please try again.';
  }
}
