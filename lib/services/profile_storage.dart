import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kMobile = 'user_mobile';

class ProfileStorage {
  ProfileStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> setMobile(String mobile) async {
    await _storage.write(key: _kMobile, value: mobile.trim());
  }

  Future<String?> getMobile() => _storage.read(key: _kMobile);

  Future<void> clear() async {
    await _storage.delete(key: _kMobile);
  }
}
