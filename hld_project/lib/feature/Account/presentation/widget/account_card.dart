import 'package:flutter/material.dart';
import '../../domain/entities/account.dart';

/// ✅ Widget hiển thị thông tin một sinh viên
class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AccountCard({
    super.key,
    required this.account,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
