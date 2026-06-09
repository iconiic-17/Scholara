part of 'motivation_cubit.dart';

abstract class MotivationState {}

class MotivationInitial extends MotivationState {}

class MotivationPicking extends MotivationState {}

class MotivationUploading extends MotivationState {}

class MotivationAnalyzing extends MotivationState {
  final String fileName;
  MotivationAnalyzing(this.fileName);
}

class MotivationAnalyzed extends MotivationState {
  final int score;
  final String verdict;
  final List<String> problems;
  final List<String> missingElements;
  final String? rewrittenLetter;

  MotivationAnalyzed({
    required this.score,
    required this.verdict,
    required this.problems,
    required this.missingElements,
    this.rewrittenLetter,
  });
}

class MotivationError extends MotivationState {
  final String message;
  MotivationError(this.message);
}
