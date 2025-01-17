import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const storage = FlutterSecureStorage();

  Future<void> logout() async {
    await storage.delete(key: 'jwt');
    await storage.delete(key: 'user_id');
  }
}