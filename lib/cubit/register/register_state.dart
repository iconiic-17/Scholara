import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String error;
  RegisterFailure(this.error);
  @override
  List<Object> get props => [error];
}

class RegisterOtpRequired extends RegisterState {
  final String email;
  RegisterOtpRequired(this.email);
  @override
  List<Object> get props => [email];
}
