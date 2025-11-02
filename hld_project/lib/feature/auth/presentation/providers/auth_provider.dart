import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart'; // Hoặc 'package:flutter/material.dart'
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class AuthProvider with ChangeNotifier {
  UserEntity? _user;

  UserEntity? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    // 1. Tự động lắng nghe thay đổi trạng thái đăng nhập
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _user = null;
    } else {
      // Lấy thông tin role từ Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Giả sử UserEntity.fromFirestore đã được định nghĩa
      _user = UserEntity.fromFirestore(doc);
    }

    // 3. Thông báo cho toàn bộ ứng dụng (GoRouter) biết trạng thái đã đổi
    notifyListeners();
  }

  // --- HÀM ĐĂNG XUẤT MỚI ---
  Future<void> signOut() async {
    try {
      // 2. Chỉ cần gọi hàm này,
      //    bước 1 và 3 sẽ tự động chạy
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
      // (Bạn có thể xử lý lỗi ở đây nếu muốn)
    }
  }
}