// file: lib/feature/Account/presentation/pages/account_list_page.dart
// BẢN "SẠCH" - NHẬN USECASE TỪ CONSTRUCTOR (APP_ROUTER)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- THÊM IMPORT NÀY
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:convert';
import 'dart:typed_data';

// (Không cần import DataSource hay Repository "bẩn" nữa)
// import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
// import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';

import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/usecases/get_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/create_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/delete_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/update_account.dart';
import 'package:hld_project/feature/Account/presentation/pages/account_form_page.dart'; // Form Sửa
import 'package:hld_project/feature/Account/presentation/pages/profile_page.dart'; // Trang Xem
import 'package:hld_project/feature/Account/data/model/account_model.dart'; // BẮT BUỘC CÓ ĐỂ PARSE


class AccountListPage extends StatefulWidget {
  // === NHẬN USECASE "SẠCH" TỪ APP_ROUTER ===
  final GetAccount getAccountUseCase;
  final CreateAccount createAccountUseCase;
  final UpdateAccount updateAccountUseCase;
  final DeleteAccount deleteAccountUseCase;

  const AccountListPage({
    Key? key,
    required this.getAccountUseCase,
    required this.createAccountUseCase,
    required this.updateAccountUseCase,
    required this.deleteAccountUseCase,
  }) : super(key: key);


  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  // === XÓA HẾT KHAI BÁO USECASE "BẨN" ===
  // late GetAccount _getAccountUseCase;
  // ... (xóa 3 cái kia)

  List<Account> _allAccounts = [];
  List<Account> _filteredAccounts = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debouncer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // === XÓA HẾT CODE "BẨN" TRONG INITSTATE ===
    // (Không cần gán widget.usecase vào _usecase nữa)
    // (Không cần tự tạo dataSource, repository...)
    // ==========================================

    _loadAccounts();
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // (Hàm tải data - ĐÃ SỬA: DÙNG 'widget.getAccountUseCase')
  Future<void> _loadAccounts() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      // === SỬA: DÙNG USECASE TỪ WIDGET (SẠCH) ===
      final dynamic rawAccounts = await widget.getAccountUseCase.call();

      final List<Account> accounts = (rawAccounts as List).map((doc) {
        if (doc is QueryDocumentSnapshot) {
          return AccountModel.fromFirestore(doc);
        }
        if (doc is Account) {
          return doc;
        }
        throw Exception('The return data type from UseCase is undefined');
      }).toList();

      // Lọc Admin
      final String? currentAdminId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (currentAdminId != null) {
        accounts.removeWhere((account) => account.id == currentAdminId);
      }
      // =======================================

      setState(() {
        _allAccounts = accounts;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
      _applyFilters();
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

  // (Hàm xóa - ĐÃ SỬA: DÙNG 'widget.deleteAccountUseCase')
  Future<void> _delete(String id) async {
    final confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm"),
        content: Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        // === SỬA: DÙNG USECASE TỪ WIDGET (SẠCH) ===
        await widget.deleteAccountUseCase.call(id);
        await _loadAccounts();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error when deleting: $e')));
      }
    }
  }

  // (Hàm mở Form Edit - ĐÃ SỬA: TRUYỀN USECASE "SẠCH" ĐI)
  Future<void> _openEditForm(Account? account) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountFormPage(
          account: account,
          // === SỬA: TRUYỀN USECASE "SẠCH" CHO FORM ===
          createAccountUseCase: widget.createAccountUseCase,
          updateAccountUseCase: widget.updateAccountUseCase,
        ),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'HLD',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            color: Colors.green,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Thanh tìm kiếm
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for user ...',
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
              'User List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Danh sách
            Expanded(
              child: _buildAccountListWidget(),
            ),
          ],
        ),
      ),
      // Nút Thêm mới
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditForm(null),
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // === HÀM BUILD LIST (ĐÃ SỬA LỖI HIỂN THỊ ẢNH) ===
  Widget _buildAccountListWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error. Please try again.'));
    }
    if (_filteredAccounts.isEmpty) {
      return const Center(child: Text('No user found.'));
    }

    // Dùng ListView
    return ListView.builder(
      itemCount: _filteredAccounts.length,
      itemBuilder: (context, index) {
        final account = _filteredAccounts[index];

        // === LOGIC DECODE ẢNH (GIỐNG PROFILE_PAGE) ===
        ImageProvider? avatarImage;
        if (account.avatarUrl.startsWith('data:image')) {
          try {
            final String base64String = account.avatarUrl.split(',')[1];
            final Uint8List imageBytes = base64Decode(base64String);
            avatarImage = MemoryImage(imageBytes);
          } catch (e) { avatarImage = null; }
        } else if (account.avatarUrl.startsWith('http')) {
          avatarImage = NetworkImage(account.avatarUrl);
        }
        // ============================================

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar (ĐÃ SỬA)
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: avatarImage,
                  child: (avatarImage == null)
                      ? const Icon(Iconsax.user, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 16),

                // Cột thông tin
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

                // Cột 2 nút (Edit/Open)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _openEditForm(account),
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
                    OutlinedButton(
                      onPressed: () => _openViewProfile(account),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        backgroundColor: Colors.grey.shade100,
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