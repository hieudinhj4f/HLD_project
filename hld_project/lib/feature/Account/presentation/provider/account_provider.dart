import 'package:flutter/material.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_account.dart';
import '../../domain/usecases/create_account.dart';
import '../../domain/entities/account.dart';
import '../../domain/usecases/update_account.dart';

class AccountProvider extends ChangeNotifier {
  final GetAccount getAccountsUseCase;
  final CreateAccount createAccountUseCase;
  final UpdateAccount updateAccountUseCase;
  final DeleteAccount deleteAccountUseCase;

  List<Account> _accounts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  AccountProvider({
    required this.getAccountsUseCase,
    required this.createAccountUseCase,
    required this.updateAccountUseCase,
    required this.deleteAccountUseCase,
  });

  Future<void> fetchAccounts() async {
    _isLoading = true;
    notifyListeners();

    _accounts = await getAccountsUseCase.call();

    _isLoading = false;
    notifyListeners();
  }

  List<Account> get filteredAccounts {
    if (_searchQuery.isEmpty) return _accounts;
    return _accounts
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    await deleteAccountUseCase.call(id);
    await fetchAccounts(); // Cập nhật lại list
  }
}
