import 'package:grantgo/Model/scholarship_model.dart';

abstract class SavedScholarshipsState {}

class SavedScholarshipsInitial extends SavedScholarshipsState {}

class SavedScholarshipsLoading extends SavedScholarshipsState {}

class SavedScholarshipsSuccess extends SavedScholarshipsState {
  final List<ScholarshipModel> savedScholarships;
  SavedScholarshipsSuccess(this.savedScholarships);
}

class SavedScholarshipsFailure extends SavedScholarshipsState {
  final String error;
  SavedScholarshipsFailure(this.error);
}

// State مؤقتة لعمليات الحفظ والحذف السريعة
class SavedActionSuccess extends SavedScholarshipsState {
  final String message;
  final String scholarshipId;
  final bool isSaved;
  SavedActionSuccess({
    required this.message,
    required this.scholarshipId,
    required this.isSaved,
  });
}
