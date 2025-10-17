import 'package:flutter/material.dart';
import 'package:hld_project/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:hld_project/feature/auth/data/repositories/auth_repository_impl.dart';
import 'package:hld_project/feature/auth/domain/usecases/login_usecase.dart';
import 'package:hld_project/feature/auth/domain/entities/user_entity.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  UserEntity? _user;
  bool _loading = false;
  String? _error;

  AuthProvider()
      : _loginUseCase =
  LoginUseCase(AuthRepositoryImpl(AuthRemoteDatasource()));

  UserEntity? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _loginUseCase(email, password);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
