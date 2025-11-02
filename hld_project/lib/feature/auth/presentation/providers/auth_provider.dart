import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class AuthProvider with ChangeNotifier {
  UserEntity? _user;
  UserEntity? get user => _user;
  String? get userId => _user?.uid; // DÙNG TRONG CART, ORDER, ADMIN
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      if (_user != null) {
        _user = null;
        notifyListeners();
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        _user = UserEntity.fromFirestore(doc);
      } else {
        // Tạo user mặc định nếu chưa có trong Firestore
        _user = UserEntity(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? 'User',
          role: 'user', createdAt: null, updatedAt: null, // Mặc định là user
        );
        // Lưu vào Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set(_user!.toMap());
      }
    } catch (e) {
      debugPrint('Lỗi lấy user: $e');
      _user = null;
    }

    notifyListeners();
  }

  // --- ĐĂNG XUẤT ---
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // _onAuthStateChanged sẽ tự gọi → _user = null
    } catch (e) {
      debugPrint('Lỗi đăng xuất: $e');
      rethrow;
    }
  }

  // --- ĐĂNG NHẬP (nếu cần thủ công) ---
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Lỗi đăng nhập: $e');
      rethrow;
    }
  }
}