import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

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

  @override
  void initState() {
    super.initState();
    _checkFirestoreConnection();
  }
  Future<void> _checkFirestoreConnection() async {
    debugPrint('Đang kiểm tra kết nối Firestore...');
    try {
      // Thử truy vấn giới hạn 1 document từ collection 'products'
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('products')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        debugPrint('✅ KẾT NỐI FIRESTORE THÀNH CÔNG và collection có dữ liệu.');
      } else {
        debugPrint('⚠️ KẾT NỐI FIRESTORE THÀNH CÔNG nhưng collection "products" rỗng.');
      }
    } on FirebaseException catch (e) {
      debugPrint('❌ KẾT NỐI FIRESTORE THẤT BẠI (Lỗi Firebase): ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('❌ KẾT NỐI THẤT BẠI VỚI LỖI CHUNG: $e');
    }
  }

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Healthy Life Diagnosis',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Iconsax.search_normal, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Tìm kiếm thuốc, bệnh lý...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Ưu đãi & Khuyến mãi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sản phẩm nổi bật',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              alignment: Alignment.center,
              height: 300,
              color: Colors.transparent,
              child: const Text(
                'PRODUCT LIST WIDGET GOES HERE',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Cart Screen"),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Chat Screen"),
    );
  }
}
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Account Screen"),
    );
  }
}