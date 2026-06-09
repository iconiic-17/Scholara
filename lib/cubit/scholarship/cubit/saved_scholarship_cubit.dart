import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:grantgo/Model/scholarship_model.dart';
import 'package:grantgo/Services/dio_client.dart';
import 'saved_scholarship_state.dart';

class SavedScholarshipsCubit extends Cubit<SavedScholarshipsState> {
  String? userToken;

  SavedScholarshipsCubit() : super(SavedScholarshipsInitial());

  void updateToken(String token) {
    userToken = token;
  }

  Future<void> fetchSavedScholarships() async {
    if (userToken == null) return;
    emit(SavedScholarshipsLoading());
    try {
      final response = await appDio.get(
        '/saved',
        options: Options(headers: {'Authorization': 'Bearer $userToken'}),
      );
      final responseData = response.data;
      if (responseData == null || responseData is! Map<String, dynamic>) {
        emit(SavedScholarshipsSuccess([]));
        return;
      }
      final scholarshipsRaw = responseData['scholarships'];
      if (scholarshipsRaw == null || scholarshipsRaw is! List) {
        emit(SavedScholarshipsSuccess([]));
        return;
      }
      final List<ScholarshipModel> savedList = (scholarshipsRaw)
          .where((item) => item != null && item is Map<String, dynamic>)
          .map(
            (item) => ScholarshipModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      emit(SavedScholarshipsSuccess(savedList));
    } catch (e) {
      emit(SavedScholarshipsFailure(e.toString()));
    }
  }

  Future<void> saveScholarship(String scholarshipId) async {
    if (userToken == null) return;
    try {
      final response = await appDio.post(
        '/saved/$scholarshipId',
        options: Options(headers: {'Authorization': 'Bearer $userToken'}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        emit(
          SavedActionSuccess(
            message:
                response.data['message'] ?? "Scholarship saved successfully",
            scholarshipId: scholarshipId,
            isSaved: true,
          ),
        );
        await fetchSavedScholarships();
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        await fetchSavedScholarships();
      } else {
        emit(SavedScholarshipsFailure("Failed to save scholarship"));
      }
    }
  }

  Future<void> removeSavedScholarship(String scholarshipId) async {
    if (userToken == null) return;
    try {
      final response = await appDio.delete(
        '/saved/$scholarshipId',
        options: Options(headers: {'Authorization': 'Bearer $userToken'}),
      );
      if (response.statusCode == 200) {
        emit(
          SavedActionSuccess(
            message:
                response.data['message'] ?? "Scholarship removed from saved",
            scholarshipId: scholarshipId,
            isSaved: false,
          ),
        );
        await fetchSavedScholarships();
      }
    } catch (e) {
      emit(SavedScholarshipsFailure("Failed to remove scholarship"));
    }
  }
}
