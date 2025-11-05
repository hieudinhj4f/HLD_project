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

  // Hàm load data (Giữ nguyên)
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


  // === SỬA HÀM NÀY ===
  Future<void> deleteAccount(String accountId) async {
    // 1. Báo là đang loading (giống fetchAccounts)
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // 2. Gọi UseCase (Xóa trên server)
      await deleteAccountUseCase.call(accountId);

      // 3. (THAY ĐỔI LỚN)
      // Nếu xóa thành công, xóa nó ra khỏi list local
      // Thay vì gọi lại fetchAccounts()
      _accounts.removeWhere((account) => account.id == accountId);

    } catch (e) {
      _errorMessage = e.toString();
    }

    // 4. Báo là xong, UI sẽ tự cập nhật list mới (hoặc báo lỗi)
    _isLoading = false;
    notifyListeners();
  }
// === HẾT SỬA ===

}