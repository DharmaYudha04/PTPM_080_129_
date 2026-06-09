import '../../../shared/models/user.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<bool> checkSession();
  Future<void> logout();
}
