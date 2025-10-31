// file: lib/feature/Account/presentation/pages/profile_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../data/model/account_model.dart';
import '../../domain/entities/account.dart';
import 'profile_edit_page.dart'; // Import trang Edit


// === 1. ĐỔI THÀNH STATEFULWIDGET ===
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Biến giữ Future để ta có thể refresh nó
  late Future<Account> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Future ngay khi widget được tạo
    _profileFuture = _fetchMyProfile();
  }

  // === HÀM LOGIC TỰ LẤY DATA (GIỮ NGUYÊN) ===
  Future<Account> _fetchMyProfile() async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('Bạn chưa đăng nhập!');
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return AccountModel.fromFirestore(doc);
        // 3. Tự parse (dùng hàm fromFirestore của Model)
        return AccountModel.fromEntity(doc);
      } else {
        throw Exception('Không tìm thấy thông tin profile.');
      }
    } catch (e) {
      throw Exception('Lỗi khi tải profile: ${e.toString()}');
    }
  }

  // Hàm helper để check null/rỗng
  String _displayValue(String? value) {
    return (value == null || value.isEmpty) ? 'Chưa cập nhật' : value;
  }

  // === HÀM CHUYỂN ACCOUNT OBJECT THÀNH MAP<STRING, STRING> THỦ CÔNG ===
  Map<String, String> _createProfileMap(Account user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'gender': user.gender,
      'dob': user.dob,
      'age': user.age,
      'address': user.address,
      'role': user.role,
      // Chuyển DateTime sang String ISO để xử lý
      'createAt': user.createAt.toIso8601String(),
      'updateAt': user.updateAt.toIso8601String(),
    };
  }

  // === WIDGET DÒNG TEXT PHẲNG ===
  Widget _buildTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.category, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text('HLD Project', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<Account>(
        // === DÙNG BIẾN STATE FUTURE MỚI ===
        future: _profileFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy dữ liệu.'));
          }

          final Account user = snapshot.data!; // Lấy data

          return SingleChildScrollView(
            child: Container(
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Iconsax.user, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  // === KHUNG THÔNG TIN TRẮNG (FLAT TEXT) ===
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField('Họ và tên', _displayValue(user.name)),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                        _buildTextField('Số điện thoại', _displayValue(user.phone)),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                        _buildTextField('Giới tính', _displayValue(user.gender)),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                        _buildTextField('Ngày sinh', _displayValue(user.dob)),
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                        _buildTextField('Địa chỉ', _displayValue(user.address)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Nút Chỉnh sửa
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // === SỬA LẠI LOGIC NÚT ONPRESSED ===
                          final Map<String, String> profileData = _createProfileMap(user);

                          final result = await context.push(
                            '/user/account/edit',
                            extra: profileData,
                          );

                          // === LOGIC REFRESH KHI QUAY VỀ ===
                          // Nếu trang Edit trả về true, ta gọi setState để tải lại Future
                          if (result == true) {
                            setState(() {
                              _profileFuture = _fetchMyProfile();
                            });
                          }
                          // ===================================
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0FFDD),
                          foregroundColor: const Color(0xFF388E3C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Chỉnh sửa thông tin',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}