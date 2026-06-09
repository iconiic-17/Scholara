import 'package:equatable/equatable.dart';
import 'package:grantgo/Model/scholarship_model.dart';

abstract class ScholarshipsState extends Equatable {
  @override
  List<Object> get props => [];
}

class ScholarshipsInitial extends ScholarshipsState {}

class ScholarshipsLoading extends ScholarshipsState {}

class ScholarshipsSuccess extends ScholarshipsState {
  final List<ScholarshipModel> scholarships;
  final int totalPages;
  ScholarshipsSuccess(this.scholarships, this.totalPages);
  @override
  List<Object> get props => [scholarships, totalPages];
}

class ScholarshipsFailure extends ScholarshipsState {
  final String error;
  ScholarshipsFailure(this.error);
  @override
  List<Object> get props => [error];
}
