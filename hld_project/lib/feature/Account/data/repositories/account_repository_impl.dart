import '../../domain/entities/account.dart';
import '../../domain/account_repository/account_repository.dart';
import '../datasource/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final IAccountRemoteDatasource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Account>> GetAccount() async {
    final models = await remoteDataSource.getAllAccounts();
    return models.map((e) => e).toList();
  }

  @override
  Future<Account> CreateAccount(Account account) async {
    await remoteDataSource.addAccount(account);
    return account;
  }

  @override
  Future<Account> UpdateAccount(Account account) async {
    await remoteDataSource.updateAccount(account);
    return account;
  }

  @override
  Future<Account> DeleteAccount(String id) async {
    await remoteDataSource.deleteAccount(id);
    // tuỳ ý có thể trả về student đã xóa, hoặc null
    return Account(
      id: id,
      name: '',
      accountCode: '',
      birthDate: DateTime.now(),
      className: '',
      gender: '',
      gpa: 0,
      phone: '',
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
    );
  }
}
