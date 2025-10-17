import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                await authProvider.login(
                  _emailController.text,
                  _passwordController.text,
                );
                if (authProvider.user != null && mounted) {
                  context.go('/home');
                }
              },
              child: authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Đăng nhập'),
            ),
            if (authProvider.error != null)
              Text(authProvider.error!,
                  style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
