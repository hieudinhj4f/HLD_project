// file: lib/feature/Account/presentation/pages/account_form_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// === IMPORT ENTITY VÀ USECASE CỦA ACCOUNT ===
// (Mày phải tự tạo 2 UseCase này và provider chúng trong main.dart)
import 'package:hld_project/feature/Account/domain/entities/account.dart';
import 'package:hld_project/feature/Account/domain/usecases/create_account.dart';
import 'package:hld_project/feature/Account/domain/usecases/update_account.dart';
import 'package:hld_project/feature/Account/data/datasource/account_remote_datasource.dart';
import 'package:hld_project/feature/Account/data/repositories/account_repository_impl.dart';

class AccountFormPage extends StatefulWidget {
  // Nó chỉ cần nhận 'account' (nếu là sửa), không cần UseCase
  final Account? account;

  const AccountFormPage({
    super.key,
    this.account,
  });

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  // 1. STATE VARIABLES
  final _formKey = GlobalKey<FormState>();

  // Controllers (y như cũ)
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  // ... (tất cả các controller khác: phone, gender, dob...)

  bool _isSaving = false;

  // === KHAI BÁO BIẾN GIỮ USECASE "BẨN" ===
  late CreateAccount _createUseCase;
  late UpdateAccount _updateUseCase;

  // 2. INIT STATE
  @override
  void initState() {
    super.initState();

    // =================================================
    // === PHẦN CODE "BẨN" (KHÔNG QUA main.dart) ===
    // 1. Tự tạo DataSource (Giả sử tên class là vậy)
    final dataSource = AccountRemoteDatasourceIpml();
    // 2. Tự tạo Repository
    final repository = AccountRepositoryImpl(remoteDataSource: dataSource);
    // 3. Tự tạo UseCase (Lưu vào biến state)
    _createUseCase = CreateAccount(repository);
    _updateUseCase = UpdateAccount(repository);
    // =================================================

    // (Code khởi tạo controller y như cũ)
    final isEditing = widget.account != null;
    final account = widget.account;

    _nameController = TextEditingController(text: isEditing ? account!.name : '');
    _emailController = TextEditingController(text: isEditing ? account!.email : '');
    // ... (khởi tạo các controller khác)
  }

  // 3. DISPOSE (y như cũ)
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    // ... (dispose các controller khác)
    super.dispose();
  }

  // 4. HÀM LƯU (y như cũ)
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isSaving = true; });

    try {
      final now = DateTime.now();
      final accountToSave = Account(
        id: widget.account?.id ?? '',
        name: _nameController.text,
        email: _emailController.text,
        // ... (lấy data từ các controller khác)

        // (Lấy các trường còn lại: phone, gender, dob, age, address, role)
        phone: '', // _phoneController.text,
        gender: '', // _genderController.text,
        dob: '', // _dobController.text,
        age: '', // _ageController.text,
        address: '', // _addressController.text,
        role: 'user', // _roleController.text,

        createAt: widget.account?.createAt ?? now,
        updateAt: now,
      );

      // Gọi UseCase "bẩn" (biến state)
      if (widget.account == null) {
        await _createUseCase.call(accountToSave);
      } else {
        await _updateUseCase.call(accountToSave);
      }

      if (mounted) Navigator.pop(context, true); // Trả về 'true' để báo list TẢI LẠI

    } catch (e) {
      // (Xử lý lỗi)
    } finally {
      if (mounted) { setState(() { _isSaving = false; }); }
    }
  }

  // 5. BUILD (UI y như cũ)
  @override
  Widget build(BuildContext context) {
    // (Toàn bộ code UI của Form: Scaffold, AppBar, Form, ListView, TextFormField...)
    // Mày chép lại code UI của AccountFormPage tao đưa lần trước vào đây
    // ...
    return Scaffold(
      appBar: AppBar(title: Text(widget.account != null ? 'Sửa' : 'Tạo')),
      // ... (Phần Form UI...)
    );
  }
}