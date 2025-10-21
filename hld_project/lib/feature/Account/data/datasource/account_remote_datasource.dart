import 'package:hld_project/feature/Account/data/model/account_model.dart';
import 'package:hld_project/feature/Account/domain/entities/account.dart';


/// Interface cơ bản định nghĩa hành vi của datasource
abstract class IAccountRemoteDatasource {
  Future<List<AccountModel>> getAllAccounts();
  Future<AccountModel> getAccountById(String id);
  Future<void> addAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
}
