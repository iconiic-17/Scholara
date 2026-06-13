part of 'interview_cubit.dart';

abstract class InterviewState {}

class InterviewInitial extends InterviewState {}

class InterviewHealthChecking extends InterviewState {}

class InterviewHealthError extends InterviewState {
  final String message;
  InterviewHealthError(this.message);
}

class InterviewStarting extends InterviewState {}

class InterviewInProgress extends InterviewState {
  final String threadId;
  final String question;
  final int questionNumber;
  final FeedbackModel? lastFeedback;

  InterviewInProgress({
    required this.threadId,
    required this.question,
    required this.questionNumber,
    this.lastFeedback,
  });
}

class InterviewSubmitting extends InterviewState {
  final String threadId;
  final String question;
  final int questionNumber;
  final FeedbackModel? lastFeedback;

  InterviewSubmitting({
    required this.threadId,
    required this.question,
    required this.questionNumber,
    this.lastFeedback,
  });
}

class InterviewComplete extends InterviewState {
  final SummaryModel summary;

  InterviewComplete({required this.summary});
}

class InterviewError extends InterviewState {
  final String message;
  final bool canRetry;

  InterviewError(this.message, {this.canRetry = true});
}
