import 'package:firebase_core/firebase_core.dart';
import 'package:hld_project/feature/Account/data/model/account_model.dart';

import '../../domain/entities/account.dart';
import '../../domain/account_repository/account_repository.dart';
import '../datasource/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDatasource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Account>> GetAccount() async {
    final models = await remoteDataSource.getAllAccounts();
    return models.map((e) => e).toList();
  }

  @override
  Future<void> CreateAccount(Account account) async {
    final model = await AccountModel.fromEntity(account);
    remoteDataSource.CreateAccount(model);
  }

  @override
  Future<void> UpdateAccount(Account account) async {
    final model = await AccountModel.fromEntity(account);
    remoteDataSource.UpdateAccount(model);
  }

  @override
  Future<void> DeleteAccount(String id) async {
    remoteDataSource.DeleteAccount(id);
  }
}
