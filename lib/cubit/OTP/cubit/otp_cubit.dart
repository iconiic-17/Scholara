import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Services/dio_client.dart';
import 'package:grantgo/Services/token_storage.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit() : super(OtpInitial());

  Future<void> verifyOtp(String email, String otp) async {
    try {
      emit(OtpLoading());
      final response = await appDio.post(
        '/auth/verify-otp',
        data: {"email": email, "otp": otp},
      );
      if (response.statusCode == 200) {
        await TokenStorage.saveToken(response.data['token']);
        emit(OtpSuccess());
      } else {
        emit(OtpFailure("Verification Failed"));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        emit(OtpFailure(e.response?.data["message"] ?? "Server Error"));
      } else {
        emit(OtpFailure("No Internet Connection"));
      }
    }
  }
}
