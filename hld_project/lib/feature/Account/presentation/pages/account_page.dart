import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/routing/app_routers.dart'; // ĐÃ SỬA: ../../ (không phải ../../../)

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chào mừng đến trang Tài khoản!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Về Trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
