import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/feature/Account/data/model/account_model.dart';
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import '../repositories/account_repository_impl.dart';
import '../../../../core/data/firebase_remote_datasource.dart';


/// Interface cơ bản định nghĩa hành vi của datasource
abstract class AccountRemoteDatasource {
  Future<List<AccountModel>> getAllAccounts();
  Future<AccountModel?> getAccountById(String id);
  Future<void> CreateAccount(AccountModel account);
  Future<void> UpdateAccount(AccountModel account);
  Future<void> DeleteAccount(String id);
}

class AccountRemoteDatasourceIpml implements AccountRemoteDatasource {
  // FirebaseRemoteDS là lớp generic giúp tương tác với Firestore
  final FirebaseRemoteDS<AccountModel> _remoteSource;

  AccountRemoteDatasourceIpml()
      : _remoteSource = FirebaseRemoteDS<AccountModel>(
    collectionName: 'users', // Tên collection trên Firestore
    fromFirestore: (doc) => AccountModel.fromEntity(doc as Account),
    toFirestore: (model) => model.toJson(),
  );

  @override
  Future<void> CreateAccount(AccountModel account) async {
    await _remoteSource.add(account);
  }

  @override
  Future<void> DeleteAccount(String id) async {
    await _remoteSource.delete(id);
  }

  @override
  Future<void> UpdateAccount(AccountModel account) async {
    await _remoteSource.update(account.id.toString(), account);
  }

  @override
  Future<AccountModel?> getAccountById(String id) async {
    final account = await _remoteSource.getById(id);
    return account;
  }

  @override
  Future<List<AccountModel>> getAllAccounts() async{
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => AccountModel.fromFirestore(doc)).toList();
  }
}
