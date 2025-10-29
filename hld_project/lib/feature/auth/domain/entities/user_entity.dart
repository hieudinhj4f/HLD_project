import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';

class UserEntity  {
  final String uid;
  final String? email;
  final String role;
  final String name;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
});
  factory UserEntity.fromFirestore(DocumentSnapshot doc){
    Map data = doc.data() as Map<String , dynamic >;
    return UserEntity(
        uid: doc.id,
        email: data['email'] ?? '',
        role: data['role'] ??'user',
        name: data['name'] ?? '',
    );
  }
}
