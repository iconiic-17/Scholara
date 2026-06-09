import 'package:dio/dio.dart';

final Dio appDio = Dio(
  BaseOptions(
    baseUrl: 'https://scholara-backend-j62n.onrender.com/api',
    connectTimeout: const Duration(minutes: 2),
    sendTimeout: const Duration(minutes: 2),
    receiveTimeout: const Duration(minutes: 5),
  ),
);
