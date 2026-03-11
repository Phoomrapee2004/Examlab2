import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio.options.baseUrl = 'https://api.example.com/api/v1/';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // เช่น เพิ่ม Token
        options.headers["Authorization"] = "Bearer YOUR_TOKEN";
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // จัดการ Error กลาง
        print('API Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }
}