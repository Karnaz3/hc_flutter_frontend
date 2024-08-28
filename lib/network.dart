import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;

  ApiService()
      : dio = Dio(BaseOptions(
          /**
         * add your backend port and IP address here
         */
          baseUrl:
              'https://5d9b-2400-1a00-b012-d2ec-5fd-c994-6657-200c.ngrok-free.app', // Set your base URL here
          // baseUrl: 'http://192.168.137.1:3000', // Set your base URL here
          // baseUrl: 'http://192.168.18.71:3000', // Set your base URL here

          connectTimeout: const Duration(milliseconds: 5000), // 5 seconds
          receiveTimeout: const Duration(milliseconds: 3000), // 3 seconds
        ));
}
