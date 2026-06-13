part of 'chat_cubit.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  final List<ChatMessage> messages;
  ChatLoading({required this.messages});
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  ChatLoaded({required this.messages});
}

class ChatError extends ChatState {
  final List<ChatMessage> messages;
  final String error;
  ChatError({required this.messages, required this.error});
}
