import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const ChatScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

//====================== Home Tab ======================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          "Welcome to Healthy Life Diagnosis!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

//====================== Cart Tab ======================
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Cart Screen"),
    );
  }
}

//====================== Chat Tab ======================
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Chat Screen"),
    );
  }
}

//====================== Account Tab ======================
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Account Screen"),
    );
  }
}
