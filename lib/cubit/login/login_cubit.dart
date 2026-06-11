import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Services/dio_client.dart';
import 'package:grantgo/Services/token_storage.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> login(String email, String password) async {
    try {
      emit(LoginLoading());
      final response = await appDio.post(
        '/auth/login',
        data: {"email": email, "password": password},
      );
      if (response.statusCode == 200) {
        await TokenStorage.saveToken(response.data['token']);
        emit(LoginSuccess());
        print(response.data['token']);
      } else {
        emit(LoginFailure("Login Failed"));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        emit(LoginFailure(e.response?.data["message"] ?? "Server Error"));
      } else {
        emit(LoginFailure("No Internet Connection"));
      }
    }
  }
}
