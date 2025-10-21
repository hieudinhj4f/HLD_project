import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseRemoteDS<T> {
  final String collectionName;
  final T Function(DocumentSnapshot<Map<String, dynamic>> doc) fromFirestore;
  final Map<String, dynamic> Function(T item) toFirestore;

  FirebaseRemoteDS({
    required this.collectionName,
    required this.fromFirestore,
    required this.toFirestore,
  });


  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection(collectionName);

  Future<List<T>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
  }

  Future<T?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return fromFirestore(doc);
  }

  Future<String> add(T item) async {
    final data = toFirestore(item);

    // tự thêm trường created_at & updated_at nếu chưa có
    data['created_at'] ??= FieldValue.serverTimestamp();
    data['updated_at'] ??= FieldValue.serverTimestamp();

    final docRef = await _collection.add(data);
    return docRef.id;
  }

  Future<void> update(String id, T item) async {
    final data = toFirestore(item);
    data['updated_at'] = FieldValue.serverTimestamp();
    await _collection.doc(id).update(data);
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  Stream<List<T>> watchAll() {
    return _collection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(fromFirestore).toList());
  }

  String? get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
