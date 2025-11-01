// file: lib/feature/Account/presentation/pages/account_list_page.dart
// BẢN "BẨN" - GIAO DIỆN 2 NÚT (ĐÃ FIX LỖI TỰ HỦY)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // <-- CẦN CÓ ĐỂ LỌC

// === IMPORT "BẨN": UI IMPORT THẲNG TẦNG DATA ===
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';
// ===============================================

// === IMPORT ENTITY, USECASE, VÀ CÁC PAGE LIÊN QUAN ===
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/usecases/get_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/create_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/delete_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/update_account.dart';
import 'package:hld_project/feature/Account/presentation/pages/account_form_page.dart'; // Form Sửa
import 'package:hld_project/feature/Account/presentation/pages/profile_page.dart'; // Trang Xem
import 'package:hld_project/feature/Account/data/model/account_model.dart'; // BẮT BUỘC CÓ ĐỂ PARSE


class AccountListPage extends StatefulWidget {
  const AccountListPage({Key? key}) : super(key: key);

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  // === KHAI BÁO BIẾN GIỮ USECASE "BẨN" ===
  late GetAccount _getAccountUseCase;
  late CreateAccount _createAccountUseCase;
  late UpdateAccount _updateAccountUseCase;
  late DeleteAccount _deleteAccountUseCase;

  // (State variables)
  List<Account> _allAccounts = [];
  List<Account> _filteredAccounts = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debouncer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // === PHẦN CODE "BẨN" (KHỞI TẠO TẠI CHỖ) ===
    final dataSource = AccountRemoteDatasourceIpml(); // (Mày tự sửa tên Ipml nếu cần)
    final repository = AccountRepositoryImpl(remoteDataSource: dataSource);
    _getAccountUseCase = GetAccount(repository);
    _createAccountUseCase = CreateAccount(repository);
    _updateAccountUseCase = UpdateAccount(repository);
    _deleteAccountUseCase = DeleteAccount(repository);
    // =================================================

    _loadAccounts(); // Tải data
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // (Hàm tải data - ĐÃ SỬA LỖI TỰ HỦY)
  Future<void> _loadAccounts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      // 1. Gọi UseCase "bẩn" (biến state)
      final dynamic rawAccounts = await _getAccountUseCase.call();

      // 2. === PARSE DATA (SỬA LỖI TYPEERROR) ===
      final List<Account> accounts = (rawAccounts as List).map((doc) {
        if (doc is QueryDocumentSnapshot) {
          return AccountModel.fromFirestore(doc);
        }
        if (doc is Account) {
          return doc;
        }
        throw Exception('Kiểu dữ liệu trả về từ UseCase không xác định');
      }).toList();
      // =============================================

      // 3. === LỌC ADMIN (FIX LỖI TỰ HỦY) ===
      final String? currentAdminId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (currentAdminId != null) {
        accounts.removeWhere((account) => account.id == currentAdminId);
      }
      // =======================================

      setState(() {
        _allAccounts = accounts; // 4. Gán data đã parse và lọc
        _error = null;
      });
    } catch (e) {
      // Hiển thị lỗi ra UI
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
      _applyFilters(); // Áp dụng filter (search)
    }
  }

  // (Hàm lọc data - Giữ nguyên)
  void _applyFilters() {
    List<Account> tempResults = _allAccounts;
    final String query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      tempResults = tempResults.where((account) {
        return account.name.toLowerCase().contains(query) ||
            (account.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    setState(() {
      _filteredAccounts = tempResults;
    });
  }

  // (Hàm xóa - Giữ nguyên)
  Future<void> _delete(String id) async {
    final confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa tài khoản này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _deleteAccountUseCase.call(id);
        await _loadAccounts();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
      }
    }
  }

  // (Hàm mở Form Edit - Giữ nguyên)
  Future<void> _openEditForm(Account? account) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountFormPage(account: account),
      ),
    );
    if (result == true) _loadAccounts();
  }

  // (Hàm mở Profile View - Giữ nguyên)
  Future<void> _openViewProfile(Account user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(account: user),
      ),
    );
    if (result == true) _loadAccounts();
  }

  // (Hàm search - Giữ nguyên)
  void _onSearchChanged(String query) {
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    _debouncer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  // ==========================================================
  // === HÀM BUILD (GIAO DIỆN DANH SÁCH 2 NÚT) ===
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Thanh tìm kiếm (Giống ảnh)
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm người dùng (tên, email)...', // <-- ĐÃ SỬA
                prefixIcon: const Icon(Iconsax.search_normal),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tiêu đề
            const Text(
              'Danh sách người dùng', // <-- ĐÃ SỬA
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Danh sách
            Expanded(
              child: _buildAccountListWidget(), // Gọi hàm build list
            ),
          ],
        ),
      ),
      // Nút Thêm mới
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditForm(null), // Mở Form (Create mode)
        backgroundColor: Colors.blue,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  // === HÀM BUILD LIST (VẼ CÁC CARD 2 NÚT) ===
  Widget _buildAccountListWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // HIỂN THỊ LỖI (NẾU CÓ)
    if (_error != null) {
      return Center(child: Text('Lỗi: $_error. Vui lòng thử lại.'));
    }
    if (_filteredAccounts.isEmpty) {
      return const Center(child: Text('Không tìm thấy người dùng nào.'));
    }

    // Dùng ListView
    return ListView.builder(
      itemCount: _filteredAccounts.length,
      itemBuilder: (context, index) {
        final account = _filteredAccounts[index];

        // Đây là Card UI (Giống ảnh Hania Piece)
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar (Giống ảnh)
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  // (Mày tự thêm logic load ảnh avatar thật ở đây)
                  child: const Icon(Iconsax.user, color: Colors.grey),
                ),
                const SizedBox(width: 16),

                // Cột thông tin (Tên, Ngày sinh, SĐT)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('${account.dob} - ${account.gender}', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      Text(account.phone, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // === CỘT 2 NÚT (EDIT VÀ OPEN) ===
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút EDIT
                    ElevatedButton(
                      onPressed: () => _openEditForm(account), // GỌI HÀM SỬA
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(80, 35),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Edit', style: TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(height: 8),
                    // Nút OPEN
                    OutlinedButton(
                      onPressed: () => _openViewProfile(account), // GỌI HÀM VIEW
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green),
                        minimumSize: const Size(80, 35),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Open', style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}