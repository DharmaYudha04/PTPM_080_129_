import '../../../../shared/models/user.dart';
import '../auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserModel> call(String email, String password) =>
      _repository.login(email, password);
}
