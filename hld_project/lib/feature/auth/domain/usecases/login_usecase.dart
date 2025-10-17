import 'package:hld_project/feature/auth/domain/entities/user_entity.dart';
import 'package:hld_project/feature/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.login(email, password);
  }
}
