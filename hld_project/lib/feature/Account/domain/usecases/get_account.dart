import '../account_repository/account_repository.dart';
import '../entities/account.dart';
class GetAccount{
  final AccountRepository repo;
  GetAccount(this.repo);

  Future<List<Account>> call() => repo.GetAccount();
}