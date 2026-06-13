class FeedbackModel {
  final Map<String, dynamic> dimensions;
  final double average;
  final bool confidenceFlag;
  final String confidenceNote;
  final String? feedbackAnswer;

  FeedbackModel({
    required this.dimensions,
    required this.average,
    required this.confidenceFlag,
    required this.confidenceNote,
    this.feedbackAnswer,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      dimensions: Map<String, dynamic>.from(json['dimensions'] ?? {}),
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      confidenceFlag: json['confidence_flag'] ?? false,
      confidenceNote: json['confidence_note'] ?? '',
      feedbackAnswer: json['feedback_answer'],
    );
  }
}

class SummaryModel {
  final Map<String, double> dimensionAverages;
  final double overallScore;
  final String strongestDimension;
  final String weakestDimension;
  final int totalConfidenceFlags;
  final List<int> flaggedQuestions;
  final int feedbackCount;
  final String recommendation;

  SummaryModel({
    required this.dimensionAverages,
    required this.overallScore,
    required this.strongestDimension,
    required this.weakestDimension,
    required this.totalConfidenceFlags,
    required this.flaggedQuestions,
    required this.feedbackCount,
    required this.recommendation,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    final rawDims = json['dimension_averages'] as Map<String, dynamic>? ?? {};
    return SummaryModel(
      dimensionAverages: rawDims.map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0.0,
      strongestDimension: json['strongest_dimension'] ?? '',
      weakestDimension: json['weakest_dimension'] ?? '',
      totalConfidenceFlags: json['total_confidence_flags'] ?? 0,
      flaggedQuestions: List<int>.from(json['flagged_questions'] ?? []),
      feedbackCount: json['feedback_count'] ?? 0,
      recommendation: json['recommendation'] ?? '',
    );
  }
}
