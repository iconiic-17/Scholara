import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:grantgo/Services/token_storage.dart';

part 'cv_state.dart';

class CvCubit extends Cubit<CvState> {
  final Dio _dio;

  String? uploadedCvUrl;
  String? _cvFilePath;
  String? _cvFileName;

  CvCubit(this._dio) : super(CvInitial());

  Future<Options> _authOptions({
    Duration? receiveTimeout,
    Duration? sendTimeout,
    String? contentType,
  }) async {
    final token = await TokenStorage.getToken();
    return Options(
      headers: {'Authorization': 'Bearer $token'},
      contentType: contentType,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    );
  }

  // ✅ يتكال لما الـ profile يكتمل — مستقل عن CV
  Future<void> runRecommendations() async {
    try {
      emit(CvGeneratingRecommendations());

      final opts = await _authOptions();
      await _dio.post('/recommendations', options: opts);

      final recsRes = await _dio.get(
        '/recommendations',
        options: await _authOptions(),
      );

      final allRecs = recsRes.data['recommendations'] as List? ?? [];

      final sorted = List<dynamic>.from(allRecs)
        ..sort((a, b) {
          final scoreA = (a['compatibilityScore'] as num?)?.toDouble() ?? 0;
          final scoreB = (b['compatibilityScore'] as num?)?.toDouble() ?? 0;
          return scoreB.compareTo(scoreA);
        });

      final top3 = sorted.take(3).toList();

      emit(CvRecommendationsReady(recommendations: top3));
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final msg = e.response?.data?['message'] ?? '';

      if (status == 400 && msg.toString().toLowerCase().contains('profile')) {
        emit(CvError('Please complete your profile before analysis.'));
        return;
      }
      emit(CvError(msg.isNotEmpty ? msg : 'Recommendations failed'));
    }
  }

  Future<void> pickAndUploadCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    emit(CvUploading());
    try {
      final formData = FormData.fromMap({
        'cv': await MultipartFile.fromFile(file.path!, filename: file.name),
      });
      final opts = await _authOptions(contentType: 'multipart/form-data');
      await _dio.post('/cv/upload', data: formData, options: opts);

      final urlRes = await _dio.get('/cv/url', options: await _authOptions());
      final cvUrl = urlRes.data['cvUrl'] as String?;

      if (cvUrl == null || cvUrl.trim().isEmpty) {
        emit(CvError('Server did not return a valid CV URL.'));
        return;
      }

      uploadedCvUrl = cvUrl.trim();
      _cvFilePath = file.path;
      _cvFileName = file.name;

      emit(CvUploaded(uploadedCvUrl!));
    } on DioException catch (e) {
      emit(CvError(e.response?.data?['message'] ?? 'Upload failed'));
    }
  }

  // ✅ دلوقتي بتفترض إن الـ recommendations اتعملت خلاص → تعمل analysis بس
  Future<void> runFullAnalysis() async {
    if (uploadedCvUrl == null || uploadedCvUrl!.trim().isEmpty) {
      emit(CvError('Please upload a PDF file first.'));
      return;
    }

    try {
      emit(CvAnalyzing());

      final analyzeOpts = await _authOptions(
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(minutes: 3),
        contentType: _cvFilePath != null ? 'multipart/form-data' : null,
      );

      if (_cvFilePath != null) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            _cvFilePath!,
            filename: _cvFileName,
          ),
        });
        await _dio.post('/cv/analyze', data: formData, options: analyzeOpts);
      } else {
        await _dio.post('/cv/analyze', options: analyzeOpts);
      }

      final analysis = await _pollAnalysis();
      if (analysis == null) {
        emit(CvError('Analysis timed out. Please try again.'));
        return;
      }

      final recsRes = await _dio.get(
        '/recommendations',
        options: await _authOptions(),
      );
      final recs = recsRes.data['recommendations'] ?? [];

      emit(CvAnalyzed(analysis: analysis, recommendations: recs));
    } on DioException catch (e) {
      final isTimeout =
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout;

      if (isTimeout && (e.response?.statusCode ?? 0) == 0) {
        emit(CvError('Analysis request timed out. Please try again.'));
        return;
      }

      emit(CvError(e.response?.data?['message'] ?? 'Something went wrong'));
    }
  }

  Future<Map<String, dynamic>?> _pollAnalysis() async {
    const maxAttempts = 30;
    const delay = Duration(seconds: 10);

    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(delay);
      try {
        final res = await _dio.get(
          '/cv/analysis',
          options: await _authOptions(),
        );
        final data = res.data as Map<String, dynamic>?;
        if (data == null) continue;
        if (data['status'] == 'completed') return data;
      } catch (_) {}
    }
    return null;
  }

  void reset() {
    uploadedCvUrl = null;
    _cvFilePath = null;
    _cvFileName = null;
    emit(CvInitial());
  }
}
