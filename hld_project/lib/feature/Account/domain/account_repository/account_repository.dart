import '../entities/account.dart';

abstract class AccountRepository {
  Future<List<Account>> GetAccount();
  Future<void> CreateAccount(Account account);
  Future<void> UpdateAccount(Account account);
  Future<void> DeleteAccount(String id);
}