import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Services/dio_client.dart';
import 'package:grantgo/Services/token_storage.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<Map<String, String>> _authHeader() async {
    final token = await TokenStorage.getToken();
    return {'Authorization': 'Bearer $token'};
  }

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final headers = await _authHeader();
      final response = await appDio.get(
        '/users/profile',
        options: Options(headers: headers),
      );
      print('==== PROFILE RESPONSE ====');
      print(response.data);
      print('==========================');
      emit(ProfileSuccess(response.data));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? nationality,
    String? fieldOfStudy,
    String? educationLevel,
    String? age,
    String? country,
    String? major,
    String? gpa,
    String? cvUrl,
    List<String>? skills,
    List<String>? certificates,
    List<Map<String, String>>? languages,
  }) async {
    try {
      final headers = await _authHeader();
      final Map<String, dynamic> data = {};
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (nationality != null && nationality.isNotEmpty) {
        data['nationality'] = nationality;
      }
      if (fieldOfStudy != null && fieldOfStudy.isNotEmpty) {
        data['fieldOfStudy'] = fieldOfStudy;
      }
      if (educationLevel != null && educationLevel.isNotEmpty) {
        data['educationLevel'] = educationLevel;
      }
      if (age != null && age.isNotEmpty) data['age'] = int.tryParse(age) ?? age;
      if (country != null && country.isNotEmpty) data['country'] = country;
      if (major != null && major.isNotEmpty) data['major'] = major;
      if (gpa != null && gpa.isNotEmpty) {
        data['gpa'] = double.tryParse(gpa) ?? gpa;
      }
      if (cvUrl != null && cvUrl.isNotEmpty) data['cvUrl'] = cvUrl;
      if (skills != null) data['skills'] = skills;
      if (certificates != null) data['certificates'] = certificates;
      if (languages != null) data['languages'] = languages;
      print('==== UPDATE DATA ====');
      print(data);
      print('=====================');
      final response = await appDio.put(
        '/users/profile',
        data: data,
        options: Options(headers: headers),
      );
      emit(ProfileUpdateSuccess(response.data['message'] ?? 'Profile updated'));
      fetchProfile();
    } catch (e) {
      if (e is DioException) {
        print('==== UPDATE ERROR ====');
        print(e.response?.data);
        print('======================');
      }
      emit(ProfileFailure('Failed to update profile'));
    }
  }
}
