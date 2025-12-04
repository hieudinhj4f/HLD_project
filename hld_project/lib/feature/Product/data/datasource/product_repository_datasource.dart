import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/data/firebase_remote_datasource.dart';
import '../model/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAll();
  Future<int?> getTotalSold(String pharmacyID);
  Future<ProductModel?> getProduct(String id);
  Future<void> add(ProductModel product);
  Future<void> update(ProductModel product);
  Future<void> delete(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseRemoteDS<ProductModel> _remoteSource;

  ProductRemoteDataSourceImpl()
      : _remoteSource = FirebaseRemoteDS<ProductModel>(
      collectionName: 'product',
      fromFirestore: (doc) => ProductModel.fromFirestore(doc),
      toFirestore: (model) => model.toJson(),
  );

  @override
  Future<List<ProductModel>> getAll() async {
    final products = await _remoteSource.getAll();
    return products;
  }

  @override
  Future<ProductModel?> getProduct(String id) async {
    final product = await _remoteSource.getById(id);
    return product;
  }

  @override
  Future<void> add(ProductModel product) async {
    await _remoteSource.add(product);
  }

  @override
  Future<void> update(ProductModel product) async {
    await _remoteSource.update(product.id.toString(), product);
  }

  @override
  Future<void> delete(String id) async {
    await _remoteSource.delete(id);
  }

  @override
  Future<int> getTotalSold(String pharmacyId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('product')
          .where('pharmacyId', isEqualTo: pharmacyId)
          .get();

      int totalSold = 0;
      for (final doc in snapshot.docs) {
        totalSold += (doc['sold'] ?? 0) as int;
      }
      return totalSold;
    } catch (e) {
      debugPrint('Error in getTotalSold: $e');
      return 0;
    }
  }
}
