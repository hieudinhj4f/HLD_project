import 'package:hld_project/feature/Account/data/model/account_model.dart';
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import '../repositories/account_repository_impl.dart';
import '../../../../core/data/firebase_remote_datasource.dart';


/// Interface cơ bản định nghĩa hành vi của datasource
abstract class IAccountRemoteDatasource {
  Future<List<AccountModel>> getAllAccounts();
  Future<AccountModel> getAccountById(String id);
  Future<void> CreateAccount(Account account);
  Future<void> UpdateAccount(Account account);
  Future<void> DeleteAccount(String id);
}

class AccountRemoteDatasourceIpml implements AccountRepositoryImpl {
  // FirebaseRemoteDS là lớp generic giúp tương tác với Firestore
  final FirebaseRemoteDS<AccountModel> _remoteSource;

  AccountRemoteDatasourceIpml()
      : _remoteSource = FirebaseRemoteDS<AccountModel>(
    collectionName: 'users', // Tên collection trên Firestore
    fromFirestore: (doc) => AccountModel.fromEntity(doc as Account),
    toFirestore: (model) => model.toJson(),
  );

  @override
  Future<List<AccountModel>> getAllAccounts() async {
    final accounts = await _remoteSource.getAll();
    return accounts;
  }

  @override
  Future<AccountModel?> GetAccounts(String id) async {
    final account = await _remoteSource.getById(id);
    return account;
  }

  @override
  Future<void> addAccount(AccountModel account) async {
    await _remoteSource.add(account);
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    await _remoteSource.update(account.id.toString(), account);
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _remoteSource.delete(id);
  }

  @override
  Future<Account> CreateAccount(Account account) {
    // TODO: implement CreateAccount
    throw UnimplementedError();
  }

  @override
  Future<void> DeleteAccount(String id) {
    // TODO: implement DeleteAccount
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> GetAccount() {
    // TODO: implement GetAccount
    throw UnimplementedError();
  }

  @override
  Future<Account> UpdateAccount(Account account) {
    // TODO: implement UpdateAccount
    throw UnimplementedError();
  }

  @override
  // TODO: implement remoteDataSource
  IAccountRemoteDatasource get remoteDataSource => throw UnimplementedError();

}
