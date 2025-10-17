import 'package:hld_project/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:hld_project/feature/auth/domain/entities/user_entity.dart';
import 'package:hld_project/feature/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await _remoteDatasource.signInWithEmail(email, password);
    if (user == null) throw Exception("Login failed");
    return UserEntity(id: user.uid, email: user.email ?? '');
  }

  @override
  Future<void> logout() => _remoteDatasource.signOut();

  @override
  UserEntity? getCurrentUser() {
    final user = _remoteDatasource.getCurrentUser();
    if (user == null) return null;
    return UserEntity(id: user.uid, email: user.email ?? '');
  }
}
