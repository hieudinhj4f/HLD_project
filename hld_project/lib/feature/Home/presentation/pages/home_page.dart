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

  @override
  void initState() {
    super.initState();
    _checkFirestoreConnection();
  }
  Future<void> _checkFirestoreConnection() async {
    debugPrint('Đang kiểm tra kết nối Firestore...');
    final firestore = FirebaseFirestore.instance;

  // Lấy tài liệu (Document) có ID là 'products' trong collection 'product'
    final snapshot = await firestore.collection('product')
        .doc('products')
        .get();

  // Kiểm tra dữ liệu
    if (snapshot.exists) {
      final data = snapshot.data();
      debugPrint('Dữ liệu lấy được: $data');
    } else {
      debugPrint('Không tìm thấy document "products"');
    }
  }

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