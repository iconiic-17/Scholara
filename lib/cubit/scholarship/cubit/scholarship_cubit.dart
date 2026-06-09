import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Model/scholarship_model.dart';
import 'package:grantgo/Services/dio_client.dart';
import 'package:grantgo/Services/token_storage.dart';
import 'scholarship_state.dart';

class ScholarshipsCubit extends Cubit<ScholarshipsState> {
  ScholarshipsCubit() : super(ScholarshipsInitial());

  int currentPage = 1;
  int totalPages = 1;
  List<ScholarshipModel> allScholarships = [];

  Future<void> getScholarships({
    String? search,
    String? fundingType,
    String? degree,
    String? nationality,
    String? gender,
    int page = 1,
  }) async {
    try {
      if (page == 1) {
        allScholarships = [];
        emit(ScholarshipsLoading());
      }
      final token = await TokenStorage.getToken();
      Map<String, dynamic> queryParams = {'page': page, 'limit': 10};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (fundingType != null) queryParams['fundingType'] = fundingType;
      if (degree != null) queryParams['degree'] = degree;
      if (nationality != null) queryParams['nationality'] = nationality;
      if (gender != null) queryParams['gender'] = gender;

      final response = await appDio.get(
        '/scholarships',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List data = response.data['scholarships'];
        currentPage = response.data['page'];
        totalPages = response.data['pages'];
        final newScholarships = data
            .map((e) => ScholarshipModel.fromJson(e))
            .toList();
        allScholarships.addAll(newScholarships);
        emit(ScholarshipsSuccess(List.from(allScholarships), totalPages));
      } else {
        emit(ScholarshipsFailure("Failed to load scholarships"));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        emit(
          ScholarshipsFailure(e.response?.data["message"] ?? "Server Error"),
        );
      } else {
        emit(ScholarshipsFailure("No Internet Connection"));
      }
    }
  }
}
