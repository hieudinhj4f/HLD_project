import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/model/account_model.dart';
import 'package:hld_project/feature/Account/domain/entities/account.dart';


class AccountRemoteDatasourceImpl implements IAccountRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'student';

  @override
  Future<List<AccountModel>> getAllAccounts() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AccountModel.fromJson({
        'id': doc.id,
        ...data,
      });
    }).toList();
  }

  @override
  Future<AccountModel> getAccountById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) throw Exception('Account not found');
    final data = doc.data()!;
    return AccountModel.fromJson({'id': doc.id, ...data});
  }

  @override
  Future<void> addAccount(Account account) async {
    final model = AccountModel.fromEntity(account);
    await _firestore.collection(_collection).add(model.toJson());
  }

  @override
  Future<void> updateAccount(Account account) async {
    final model = AccountModel.fromEntity(account);
    await _firestore.collection(_collection).doc(account.id).update(model.toJson());
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
