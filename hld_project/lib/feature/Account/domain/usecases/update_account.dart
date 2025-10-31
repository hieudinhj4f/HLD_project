import '../account_repository/account_repository.dart';
import '../entities/account.dart';

class UpdateAccount{
  final AccountRepository repo;
  UpdateAccount(this.repo);

  Future<void> call(Account account) => repo.UpdateAccount(account);
}