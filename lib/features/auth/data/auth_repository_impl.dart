import '../../../shared/models/user.dart';
import '../domain/auth_repository.dart';
import 'auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthLocalDataSource _dataSource;

  @override
  Future<bool> checkSession() => _dataSource.checkSession();

  @override
  Future<UserModel> login(String email, String password) =>
      _dataSource.login(email, password);

  @override
  Future<void> logout() => _dataSource.logout();

  @override
  Future<UserModel> register(String name, String email, String password) {
    return _dataSource.register(name, email, password);
  }
}
