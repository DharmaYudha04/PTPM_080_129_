import '../../../../shared/models/user.dart';
import '../auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserModel> call(String name, String email, String password) {
    return _repository.register(name, email, password);
  }
}
