import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get apiBaseUrl {
    if (dotenv.isInitialized) {
      final v = dotenv.maybeGet('API_BASE_URL')?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return const String.fromEnvironment('API_BASE_URL', defaultValue: '');
  }

  static bool get usesRestBackend => apiBaseUrl.isNotEmpty;

  static String get apiKey {
    if (dotenv.isInitialized) {
      final v = dotenv.maybeGet('BLOGGER_API_KEY')?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return const String.fromEnvironment('BLOGGER_API_KEY', defaultValue: '');
  }

  static String get blogId {
    if (dotenv.isInitialized) {
      final v = dotenv.maybeGet('BLOGGER_BLOG_ID')?.trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return const String.fromEnvironment('BLOGGER_BLOG_ID', defaultValue: '');
  }

  static const int postsPageSize = 10;
}
