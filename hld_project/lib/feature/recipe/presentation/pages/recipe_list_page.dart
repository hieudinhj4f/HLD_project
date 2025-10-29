// lib/presentation/pages/recipe_list_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
// Domain
import '../../domain/entity/recipe.dart';
import '../../domain/usecase/createRecipe.dart';
import '../../domain/usecase/getRecipe.dart';
import '../../domain/usecase/deleteRecipe.dart';
import '../../domain/usecase/updateRecipe.dart';
// Pages
import '../pages/recipe_form_page.dart';
// Widgets
import '../widget/recipe_card.dart'; // (Tưởng tượng bạn có file này)

// Danh sách thể loại cố định
const List<String> categories = [
  'Tất cả', 'Món chính', 'Tráng miệng', 'Ăn sáng', 'Thức uống'
];

class RecipeListPage extends StatefulWidget {
  // 1. Nhận UseCase qua constructor
  final GetRecipesUseCase getRecipesUseCase;
  final CreateRecipeUseCase createRecipeUseCase;
  final UpdateRecipeUseCase updateRecipeUseCase;
  final DeleteRecipeUseCase deleteRecipeUseCase;

  const RecipeListPage({
    super.key,
    required this.getRecipesUseCase,
    required this.createRecipeUseCase,
    required this.updateRecipeUseCase,
    required this.deleteRecipeUseCase,
  });

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  // 2. Quản lý State cục bộ
  List<Recipe> _recipes = [];
  String _selectedCategory = 'Tất cả';
  bool _isLoading = false;
  String? _error;
  Timer? _debouncer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipes(); // Tải danh sách khi bắt đầu
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    _searchController.dispose();
    super.dispose();

  // 3. Hàm gọi UseCase và cập nhật State
  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Gọi UseCase với các bộ lọc hiện tại
      final recipes = await widget.getRecipesUseCase.call(
        category: _selectedCategory,
        searchQuery: _searchController.text.trim(),
      );
      setState(() {
        _recipes = recipes;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Xử lý debounce khi tìm kiếm
  void _onSearchChanged(String query) {
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    _debouncer = Timer(const Duration(milliseconds: 500), () {
      _loadRecipes(); // Gọi lại API với từ khóa mới
    });
  }

  // Xử lý khi chọn Dropdown
  void _onCategoryChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCategory = newValue;
      });
      _loadRecipes(); // Gọi lại API với category mới
    }
  }

  // Mở trang Form
  Future<void> _openForm([Recipe? recipe]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeFormPage(
          recipe: recipe,
          // 4. Truyền UseCase cho trang Form
          createUseCase: widget.createRecipeUseCase,
          updateUseCase: widget.updateRecipeUseCase,
        ),
      ),
    );
    if (result == true) {
      _loadRecipes(); // Tải lại danh sách nếu Form trả về true
    }
  }

  // Xử lý Xóa
  Future<void> _deleteRecipe(String id) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa món ăn này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.deleteRecipeUseCase.call(id);
        _loadRecipes(); // Tải lại
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Công thức"),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _isLoading ? null : _loadRecipes,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(), // Thanh tìm kiếm & Lọc
          _buildRecipeList(), // Danh sách
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Iconsax.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Tìm theo tên món ăn...',
              prefixIcon: Icon(Iconsax.search_normal),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedCategory,
            items: categories.map((String cat) {
              return DropdownMenuItem<String>(value: cat, child: Text(cat));
            }).toList(),
            onChanged: _onCategoryChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    if (_isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Expanded(child: Center(child: Text('Lỗi: $_error')));
    }
    if (_recipes.isEmpty) {
      return const Expanded(child: Center(child: Text('Không có món ăn nào.')));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          // Bạn có thể tạo RecipeCard() tương tự ProductCard
          return Card(
            child: ListTile(
              leading: Image.network(recipe.imageUrl, width: 50, fit: BoxFit.cover, errorBuilder: (c,e,s)=>Icon(Icons.image)),
              title: Text(recipe.name),
              subtitle: Text("${recipe.category} - ${recipe.time} phút"),
              onTap: () => _openForm(recipe),
              trailing: IconButton(
                icon: const Icon(Iconsax.trash, color: Colors.red),
                onPressed: () => _deleteRecipe(recipe.id!),
              ),
            ),
          );
        },
      ),
    );
  }
}