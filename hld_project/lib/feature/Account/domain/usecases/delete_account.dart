import '../account_repository/account_repository.dart';

class DeleteAccount{
  final AccountRepository repo;
  DeleteAccount(this.repo);

  Future<void>  call(String id) => repo.DeleteAccount(id);
}