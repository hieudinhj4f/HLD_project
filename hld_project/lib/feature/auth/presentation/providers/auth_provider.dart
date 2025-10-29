import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart'; // Hoặc 'package:flutter/material.dart'
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

// (Bạn có một import 'providers.dart' và 'firebase_auth.dart' bị trùng, tôi đã xóa bớt)

class AuthProvider with ChangeNotifier {
  UserEntity? _user;

  // SỬA LỖI 1: Đổi 'User' (viết hoa) thành 'user' (viết thường)
  UserEntity? get user => _user;

  // SỬA LỖI 2: Đổi 'isLoggin' thành 'isLoggedIn'
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  // Tên 'User' (viết hoa) ở tham số là đúng, vì nó đến từ Firebase
  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _user = null;
    } else {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Giả sử UserEntity.fromFirestore đã được định nghĩa
      _user = UserEntity.fromFirestore(doc);
    }

    // Rất quan trọng, phải có hàm này
    notifyListeners();
  }
}