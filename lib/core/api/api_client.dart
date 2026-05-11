import 'package:dio/dio.dart';

import '../constants/app_constant.dart';

class ApiClient {
  late final Dio dio;
  late final bool isRestBackend;
  ApiClient() {
    final rest = AppConstants.apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    isRestBackend = rest.isNotEmpty;
    final baseUrl = isRestBackend
        ? rest
        : 'https://www.googleapis.com/blogger/v3/blogs/${AppConstants.blogId}';
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (s) => s != null && s < 500,
      ),
    );
  }
}
