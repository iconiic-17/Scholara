import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Services/dio_client.dart';
import 'package:grantgo/Services/token_storage.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> getMe() async {
    try {
      emit(AuthLoading());
      String? token = await TokenStorage.getToken();
      final response = await appDio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      emit(AuthSuccess(response.data));
    } on DioException catch (e) {
      emit(AuthFailure(e.response?.data['message'] ?? 'Auth Error'));
    }
  }
}
