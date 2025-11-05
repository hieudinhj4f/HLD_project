// file: lib/feature/Account/data/repositories/account_repository_impl.dart
// BẢN SẠCH - ĐÃ SỬA LỖI NULLABILITY (GetAccountById)

import 'package:hld_project/feature/Account/data/model/account_model.dart';
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/account_repository/account_repository.dart';
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {

  final AccountRemoteDatasource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  // (Hàm này mày dùng tên G hoa)
  @override
  Future<List<Account>> GetAccount() async {
    return await remoteDataSource.getAllAccounts();
  }

  // === SỬA HÀM NÀY (ĐỂ CHECK NULL) ===
  @override
  Future<Account> GetAccountById(String id) async {
    // 1. Lấy data (Nó có thể là null, kiểu AccountModel?)
    final model = await remoteDataSource.getAccountById(id);

    // 2. Kiểm tra null (BẮT BUỘC)
    if (model == null) {
      // Nếu không tìm thấy, mày phải báo lỗi
      throw Exception('Không tìm thấy tài khoản với ID: $id');
    }

    // 3. Nếu không null, trả về (vì AccountModel cũng là Account)
    return model;
  }
  // ===================================

  // (Hàm này mày dùng C hoa)
  @override
  Future<void> CreateAccount(Account account) async {
    final model = AccountModel.fromEntity(account);
    return await remoteDataSource.CreateAccount(model); // (Giả sử DS gọi là addAccount)
  }

  // (Hàm này mày dùng U hoa)
  @override
  Future<void> UpdateAccount(Account account) async {
    final model = AccountModel.fromEntity(account);
    return await remoteDataSource.UpdateAccount(model); // (Giả sử DS gọi là updateAccount)
  }

  // (Hàm này mày dùng D hoa)
  @override
  Future<void> DeleteAccount(String id) async {
    return await remoteDataSource.DeleteAccount(id);
  }
}