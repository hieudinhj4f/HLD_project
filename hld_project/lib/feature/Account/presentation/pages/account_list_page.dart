import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/account_card.dart';
import '../provider/account_provider.dart';

/// ✅ Trang hiển thị danh sách sinh viên
class AccountListPage extends StatefulWidget {
  const AccountListPage({super.key});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<AccountProvider>(context, listen: false).fetchAccounts());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách người dùng'),
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: provider.accounts.length,
              itemBuilder: (context, index) {
                final account = provider.accounts[index];
                return AccountCard(
                  account: account,
                  onDelete: () =>
                      provider.deleteAccount(account.id.toString()), onEdit: () {  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Chuyển sang màn thêm người dùng
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}