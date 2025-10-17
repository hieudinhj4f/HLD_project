import 'package:hld_project/feature/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
  UserEntity? getCurrentUser();
}
