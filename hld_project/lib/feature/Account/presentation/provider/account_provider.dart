// file: lib/presentation/providers/account_provider.dart
import 'package:flutter/material.dart';
import 'package:hld_project/feature/Account/domain/usecases/get_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/delete_account.dart';
import 'package:hld_project/feature/Account/domain/entities/account.dart';

class AccountProvider with ChangeNotifier {
  // Chỉ cần 1 UseCase này (giả sử nó là GetAccounts)
  final GetAccount getAccount;
  final DeleteAccount deleteAccountUseCase;

  AccountProvider({
    required this.getAccount,
    required this.deleteAccountUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Hàm load data
  Future<void> fetchAccounts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _accounts = await getAccount.call(); // Gọi GetAccount usecase
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteAccount(String accountId) async {
    _errorMessage = '';
    try {
      // 1. Gọi UseCase
      await deleteAccountUseCase.call(accountId);

      // 2. Tải lại danh sách
      await fetchAccounts();

    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}