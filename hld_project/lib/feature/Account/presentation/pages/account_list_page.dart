import 'dart:async';

import '../../domain/entities/account.dart';
import '../../domain/usecases/create_account.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/update_account.dart';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/account_card.dart'; // <-- THAY ĐỔI

// Import các Usecase mà Page này cần

class AccountListPage extends StatefulWidget {
  final GetAllAccounts getAccounts;
  final CreateAccount createAccount;
  final UpdateAccount updateAccount;
  final DeleteAccount deleteAccount;

  const AccountListPage({
    Key? key,
    required this.getAccounts,
    required this.createAccount,
    required this.updateAccount,
    required this.deleteAccount,
  }) : super(key: key);

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  List<Account> _allAccounts = [];
  List<Account> _filteredAccounts = [];
  List<String> _roles = ['All', 'user', 'admin'];
  String _selectedRole = 'All';

  bool _isLoading = false;
  String? _error;
  Timer? _debouncer;

  final TextEditingController _searchController = TextEditingController();

  // === THAY ĐỔI 1: Thêm state để theo dõi người dùng được chọn ===
  Account? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _checkFirestoreConnection();
    _loadAccounts();
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkFirestoreConnection() async {
    // (Không thay đổi, giữ nguyên)
    debugPrint('Đang kiểm tra kết nối Firestore...');
    final firestore = FirebaseFirestore.instance;
    try {
      final snapshot = await firestore.collection('users').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint('✅ KẾT NỐI FIRESTORE (users) THÀNH CÔNG');
      } else {
        debugPrint('✅ KẾT NỐI FIRESTORE THÀNH CÔNG, nhưng collection "users" trống.');
      }
    } on FirebaseException catch (e) {
      debugPrint('❌ LỖI FIRESTORE: ${e.code}');
    } catch (e) {
      debugPrint('❌ LỖI KHÁC: $e');
    }
  }

  Future<void> _loadAccounts() async {
    // (Không thay đổi, giữ nguyên)
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final accounts = await widget.getAccounts.call();
      setState(() {
        _allAccounts = accounts;
        _error = null;
        if (!_roles.contains(_selectedRole)) {
          _selectedRole = 'All';
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
      _applyFilters();
    }
  }

  void _applyFilters() {
    // (Không thay đổi, giữ nguyên)
    List<Account> tempResults = _allAccounts;
    final String query = _searchController.text.toLowerCase();

    if (_selectedRole != 'All') {
      tempResults = tempResults.where((account) {
        return account.role == _selectedRole;
      }).toList();
    }

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

  // === THAY ĐỔI 2: Cập nhật hàm delete để xóa lựa chọn nếu cần ===
  Future<void> _delete(String id) async {
    // Nếu người dùng bị xóa là người đang được chọn, hãy bỏ chọn
    if (_selectedAccount?.id == id) {
      setState(() {
        _selectedAccount = null;
      });
    }
    await widget.deleteAccount(id);
    await _loadAccounts();
  }

  // (Hàm _openForm không đổi, vẫn dùng để Mở Form Thêm Mới hoặc Sửa)
  Future<void> _openForm([Account? account]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AccountFormPage(
          account: account,
          createUseCase: widget.createAccount,
          updateUseCase: widget.updateAccount,
        ),
      ),
    );
    if (result == true) _loadAccounts();
  }

  void _onSearchChanged(String query) {
    // (Không thay đổi, giữ nguyên)
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    _debouncer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  // === THAY ĐỔI 3: Sửa _buildAccountList để xử lý việc chọn ===
  Widget _buildAccountList() {
    if (_isLoading && _allAccounts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Lỗi: $_error. Vui lòng thử lại.'));
    }
    if (_filteredAccounts.isEmpty) {
      if (_searchController.text.isNotEmpty || _selectedRole != 'All') {
        return const Center(child: Text('Không tìm thấy người dùng phù hợp.'));
      }
      return const Center(child: Text('Không có người dùng nào.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredAccounts.length,
      itemBuilder: (context, index) {
        final account = _filteredAccounts[index];
        final isSelected = _selectedAccount?.id == account.id; // Kiểm tra xem có đang được chọn không

        return AccountCard(
          account: account,
          isSelected: isSelected, // <-- Truyền trạng thái này vào Card
          onTap: () { // <-- Thêm hàm onTap
            setState(() {
              _selectedAccount = account;
            });
          },
          // (Bỏ onEdit và onDelete ở đây để giao diện gọn hơn,
          //  chuyển các nút này sang panel chi tiết)
          // onEdit: () => _openForm(account),
          // onDelete:  () => _delete(account.id),
        );
      },
    );
  }

  // === THAY ĐỔI 4: Tạo _buildListPanel (Panel bên trái) ===
  Widget _buildListPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh tìm kiếm
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm người dùng (tên, email)...',
              prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Iconsax.close_circle, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Dropdown lọc theo Role
          Container(
            // ... (giữ nguyên code Dropdown)
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedRole,
                icon: const Icon(Iconsax.arrow_down_1),
                items: _roles.map((String roleName) {
                  return DropdownMenuItem<String>(
                    value: roleName,
                    child: Text(roleName),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() { _selectedRole = newValue; });
                    _applyFilters();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Tất cả người dùng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Danh sách
          _buildAccountList(),
        ],
      ),
    );
  }

  // === THAY ĐỔI 5: Tạo _buildDetailPanel (Panel bên phải) ===
  Widget _buildDetailPanel() {
    // Nếu đang tải và chưa chọn ai, hiển thị loading
    if (_isLoading && _allAccounts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Nếu không có ai được chọn, hiển thị hướng dẫn
    if (_selectedAccount == null) {
      return const Center(
        child: Text(
          'Chọn một người dùng từ danh sách để xem chi tiết',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Nếu đã chọn, hiển thị chi tiết
    final account = _selectedAccount!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            account.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(account.role),
            backgroundColor: account.role == 'admin' ? Colors.blue.shade100 : Colors.grey.shade200,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          _buildDetailRow(Iconsax.direct, account.email ?? 'Chưa có email'),
          _buildDetailRow(Iconsax.call, account.phone ?? 'Chưa có SĐT'),
          _buildDetailRow(Iconsax.location, account.address ?? 'Chưa có địa chỉ'),
          _buildDetailRow(Iconsax.calendar, account.dob ?? 'Chưa có ngày sinh'),
          _buildDetailRow(Iconsax.user, account.gender ?? 'Chưa có giới tính'),

          const SizedBox(height: 32),
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Iconsax.edit),
                label: const Text('Chỉnh sửa'),
                onPressed: () => _openForm(account), // Nút sửa
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                icon: const Icon(Iconsax.trash, color: Colors.red),
                label: const Text('Xóa'),
                onPressed: () => _delete(account.id), // Nút xóa
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
  // (Widget phụ trợ cho panel chi tiết)
  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }


  // === THAY ĐỔI 6: Cập nhật hàm Build() chính ===
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản lý Người dùng',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.black),
            onPressed: _isLoading ? null : _loadAccounts,
          ),
        ],
      ),
      // Thay đổi toàn bộ body thành Row
      body: Row(
        children: [
          // Panel trái (Danh sách)
          Expanded(
            flex: 1, // Panel này chiếm 1/3
            child: _buildListPanel(),
          ),
          // Đường kẻ phân chia
          const VerticalDivider(thickness: 1, width: 1),
          // Panel phải (Chi tiết)
          Expanded(
            flex: 2, // Panel này chiếm 2/3 (rộng hơn)
            child: _buildDetailPanel(),
          ),
        ],
      ),
      // Nút Thêm mới vẫn giữ nguyên
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        backgroundColor: Colors.blue,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }
}
