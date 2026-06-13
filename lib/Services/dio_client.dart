import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Dio appDio =
    Dio(
        BaseOptions(
          baseUrl: 'https://scholara-backend-j62n.onrender.com/api',
          connectTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 5),
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );
