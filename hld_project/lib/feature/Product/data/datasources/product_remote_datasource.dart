import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<DocumentSnapshot?> getProductById(String id); // THÊM DÒNG NÀY
  Future<void> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _firestore.collection('product').get();
    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  @override
  Future<DocumentSnapshot?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('product').doc(id).get();
      return doc.exists ? doc : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createProduct(ProductModel product) async {
    await _firestore.collection('product').add(product.toJson());
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('product')
        .doc(product.id)
        .update(product.toJson());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _firestore.collection('product').doc(id).delete();
  }
}
