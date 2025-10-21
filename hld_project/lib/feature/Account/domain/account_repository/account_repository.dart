import '../entities/account.dart';

abstract class AccountRepository {
  Future<List<Account>> GetAccount();
  Future<Account> CreateAccount(Account account);
  Future<Account> UpdateAccount(Account account);
  Future<Account> DeleteAccount(String id);
}