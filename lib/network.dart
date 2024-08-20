import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;

  ApiService()
      : dio = Dio(BaseOptions(
          baseUrl: 'http://192.168.1.188:3000', // Set your base URL here
          connectTimeout: const Duration(milliseconds: 5000), // 5 seconds
          receiveTimeout: const Duration(milliseconds: 3000), // 3 seconds
        ));
}
