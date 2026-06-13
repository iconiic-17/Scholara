import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:grantgo/Services/dio_client.dart';

part 'chat_state.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(
      ChatMessage(text: text.trim(), isUser: true, time: DateTime.now()),
    );
    emit(ChatLoading(messages: List.from(_messages)));

    try {
      final response = await appDio.post(
        '/chat',
        data: {'message': text.trim()},
        options: Options(
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final answer = response.data['answer'] as String? ?? '';
      _messages.add(
        ChatMessage(text: answer, isUser: false, time: DateTime.now()),
      );
      emit(ChatLoaded(messages: List.from(_messages)));
    } on DioException catch (e) {
      final msg = _parseError(e);
      emit(ChatError(messages: List.from(_messages), error: msg));
    }
  }

  void clearError() {
    emit(ChatLoaded(messages: List.from(_messages)));
  }

  String _parseError(DioException e) {
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'The AI is taking longer than usual. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection.';
    }
    if (e.response?.statusCode == 500) {
      return 'Chatbot service unavailable. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }
}
