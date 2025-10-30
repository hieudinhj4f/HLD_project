import '../entities/account.dart';
import '../account_repository/account_repository.dart';

class CreateAccount{
  final AccountRepository repo;
  CreateAccount(this.repo);

  Future<void> call(Account account)  =>   repo.CreateAccount(account);
}