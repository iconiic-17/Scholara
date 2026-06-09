import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:grantgo/Services/token_storage.dart';

part 'motivation_state.dart';

class MotivationCubit extends Cubit<MotivationState> {
  final Dio _dio;

  static const String _baseUrl = 'https://scholara-backend-j62n.onrender.com';

  String? _filePath;
  String? _fileName;

  MotivationCubit(this._dio) : super(MotivationInitial());

  Future<void> pickAndAnalyze() async {
    try {
      print('=== PICKING FILE ===');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) {
        print('User cancelled picking file');
        return;
      }

      final file = result.files.first;

      print('Selected File: ${file.name}');
      print('File Path: ${file.path}');
      print('Extension: ${file.extension}');

      if (file.extension?.toLowerCase() != 'pdf') {
        emit(MotivationError('Please select a PDF file only.'));
        return;
      }

      if (file.path == null) {
        emit(MotivationError('Cannot get file path.'));
        return;
      }

      _filePath = file.path;
      _fileName = file.name;

      emit(MotivationAnalyzing(_fileName!));

      print('=== GETTING TOKEN ===');

      final token = await TokenStorage.getToken();

      if (token == null) {
        emit(MotivationError('Unauthorized. Please login again.'));
        return;
      }

      print('Token exists ✔');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_filePath!, filename: _fileName),
      });

      final url = '$_baseUrl/api/motivation/analyze';

      print('=== SENDING REQUEST ===');
      print('URL: $url');

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 130),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      print('=== RESPONSE RECEIVED ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.data is! Map) {
        emit(MotivationError('Invalid server response format.'));
        return;
      }

      final data = Map<String, dynamic>.from(response.data);

      emit(
        MotivationAnalyzed(
          score: (data['score'] as num?)?.toInt() ?? 0,
          verdict: data['verdict']?.toString() ?? '',
          problems: _toStringList(data['problems']),
          missingElements: _toStringList(data['missing_elements']),
          rewrittenLetter: data['rewritten_letter']?.toString(),
        ),
      );
    } on DioException catch (e) {
      print('=== DIO ERROR ===');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');

      final status = e.response?.statusCode;

      String msg;

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = 'Request timed out. Please try again.';
      } else if (status == 400) {
        msg = _extractMessage(e.response?.data) ?? 'Invalid file.';
      } else if (status == 401) {
        msg = 'Unauthorized. Please login again.';
      } else if (status == 504) {
        msg = 'AI service timed out. Please try again.';
      } else {
        msg = _extractMessage(e.response?.data) ?? 'Something went wrong.';
      }

      emit(MotivationError(msg));
    } catch (e, s) {
      print('=== GENERAL ERROR ===');
      print(e);
      print(s);

      emit(MotivationError('Unexpected error occurred'));
    }
  }

  void reset() {
    _filePath = null;
    _fileName = null;
    emit(MotivationInitial());
  }

  List<String> _toStringList(dynamic val) {
    if (val is List) {
      return val.map((e) => e.toString()).toList();
    }
    return [];
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      return data['detail']?.toString() ?? data['message']?.toString();
    }
    return null;
  }
}
