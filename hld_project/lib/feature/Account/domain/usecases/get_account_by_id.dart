import '../account_repository/account_repository.dart';
import '../entities/account.dart';
class GetAccountById{
  final AccountRepository repo;
  GetAccountById(this.repo);

  Future<List<Account>> call() => repo.GetAccount();
}