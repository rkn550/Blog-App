class AppValidators {
  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(s)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? name(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Name is required';
    if (s.length < 2) return 'Name is too short';
    return null;
  }

  static String? mobile(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Mobile is required';
    final digits = RegExp(r'^[0-9+\s()-]{8,}$');
    if (!digits.hasMatch(s)) return 'Enter a valid mobile number';
    return null;
  }
}
