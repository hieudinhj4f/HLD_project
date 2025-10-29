import 'package:cloud_firestore/cloud_firestore.dart';
// Giả sử bạn có file generic này
import '../../../../core/data/firebase_remote_datasource.dart';
// Import model của Recipe
import '../model/recipe_model.dart';

/// 🔹 Hợp đồng (abstract class) cho nguồn dữ liệu Recipe
abstract class RecipeRemoteDataSource {
  // ĐÃ THÊM PHƯƠNG THỨC getRecipes (CÓ LỌC)
  Future<List<RecipeModel>> getRecipes({String? category, String? searchQuery});

  Future<List<RecipeModel>> getAll();
  Future<RecipeModel?> getRecipe(String id);
  Future<void> add(RecipeModel recipe);
  Future<void> update(RecipeModel recipe);
  Future<void> delete(String id);
}

/// 🔹 Triển khai (implementation) của DataSource
class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final FirebaseRemoteDS<RecipeModel> _remoteSource;


  final FirebaseFirestore firestore;


  CollectionReference get _recipes => firestore.collection('recipes');


  RecipeRemoteDataSourceImpl(this.firestore)
      : _remoteSource = FirebaseRemoteDS<RecipeModel>(
    collectionName: 'recipes',
    fromFirestore: (doc) => RecipeModel.fromFirestore(doc),
    toFirestore: (model) => model.toJson(),
  );

  @override
  Future<List<RecipeModel>> getRecipes({String? category, String? searchQuery}) async {

    // 1. Bắt đầu với collection
    Query query = _recipes;

    // 2. Lọc theo category (luôn áp dụng)
    if (category != null && category != 'Tất cả') {
      query = query.where('category', isEqualTo: category);
    }

    // 3. KIỂM TRA ĐIỀU KIỆN (ĐÂY LÀ PHẦN SỬA)
    final bool isSearching = searchQuery != null && searchQuery.isNotEmpty;

    if (isSearching) {
      // 🔹 NẾU NGƯỜI DÙNG TÌM KIẾM:
      // Chỉ áp dụng bộ lọc TÊN
      // BỎ sắp xếp theo 'time' để tránh lỗi Index
      query = query
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    } else {
      // 🔹 NẾU NGƯỜI DÙNG KHÔNG TÌM KIẾM:
      // Chỉ sắp xếp theo 'time'
      query = query.orderBy('time', descending: false);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
  }
  // -----------------------------------------------------------------


  @override
  Future<List<RecipeModel>> getAll() async {
    // (Hàm này vẫn dùng lớp generic bình thường)
    final recipes = await _remoteSource.getAll();
    return recipes;
  }

  @override
  Future<RecipeModel?> getRecipe(String id) async {
    final recipe = await _remoteSource.getById(id);
    return recipe;
  }

  @override
  Future<void> add(RecipeModel recipe) async {
    await _remoteSource.add(recipe);
  }

  @override
  Future<void> update(RecipeModel recipe) async {
    if (recipe.id == null) {
      throw Exception("Recipe ID không được null khi cập nhật");
    }
    await _remoteSource.update(recipe.id!, recipe);
  }

  @override
  Future<void> delete(String id) async {
    await _remoteSource.delete(id);
  }
}