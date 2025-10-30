import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/account.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_account.dart';
import '../widget/account_card.dart';
import '../provider/account_provider.dart';

class AccountListPage extends StatefulWidget {
  const AccountListPage({Key? key}) : super(key: key);

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  // Dùng 1 cái Future để FutureBuilder nó bám vào
  late Future<List<Account>> _accountsFuture;

  // Lấy UseCase ra
  late final GetAccount _getAccountUseCase;
  late final DeleteAccount _deleteAccountUseCase;

  @override
  void initState() {
    super.initState();
    // Lấy UseCase từ Provider (chỉ 1 lần)
    _getAccountUseCase = context.read<GetAccount>();
    _deleteAccountUseCase = context.read<DeleteAccount>();

    // Gọi hàm load data
    _accountsFuture = _getAccountUseCase.call();
  }

  // Hàm để load lại data (sau khi xóa)
  void _refreshData() {
    setState(() {
      _accountsFuture = _getAccountUseCase.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // (AppBar...)
      body: FutureBuilder<List<Account>>(
        future: _accountsFuture, // Bám vào cái Future
        builder: (context, snapshot) {

          // Đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Bị lỗi
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          // Không có data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không tìm thấy tài khoản nào.'));
          }

          // Có data
          final accounts = snapshot.data!;
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                title: Text(account.name),
                subtitle: Text(account.email),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // GỌI THẲNG USECASE KHI XÓA
                    try {
                      await _deleteAccountUseCase.call(account.id);
                      // Tải lại list
                      _refreshData();
                    } catch (e) {
                      // Báo lỗi
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      // (FloatingActionButton...)
    );
  }
}