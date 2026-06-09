part of 'cv_cubit.dart';

abstract class CvState {}

class CvInitial extends CvState {}

class CvUploading extends CvState {}

class CvUploaded extends CvState {
  final String cvUrl;
  CvUploaded(this.cvUrl);
}

class CvGeneratingRecommendations extends CvState {}

class CvAnalyzing extends CvState {}

class CvAnalyzed extends CvState {
  final Map<String, dynamic> analysis;
  final List<dynamic> recommendations;
  CvAnalyzed({required this.analysis, required this.recommendations});
}

class CvError extends CvState {
  final String message;
  CvError(this.message);
}
