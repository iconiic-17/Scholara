import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Services/dio_client.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  Future<void> register(String name, String email, String password) async {
    try {
      emit(RegisterLoading());
      final response = await appDio.post(
        '/auth/register',
        data: {
          "name": name,
          "email": email,
          "password": password,
          "confirmPassword": password,
        },
      );
      if (response.statusCode == 201) {
        emit(RegisterSuccess());
      } else {
        emit(RegisterFailure("Register Failed"));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        emit(RegisterFailure(e.response?.data["message"] ?? "Server Error"));
      } else {
        emit(RegisterFailure("No Internet Connection"));
      }
    }
  }
}
