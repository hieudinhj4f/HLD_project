import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() => _firebaseAuth.currentUser;
}
