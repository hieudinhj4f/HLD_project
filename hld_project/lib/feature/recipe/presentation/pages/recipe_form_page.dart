// lib/presentation/pages/recipe_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hld_project/feature/recipe/presentation/pages/recipe_list_page.dart';
import '../../domain/entity/recipe.dart';
import '../../domain/usecase/createRecipe.dart';
import '../../domain/usecase/updateRecipe.dart';

class RecipeFormPage extends StatefulWidget {
  final Recipe? recipe; // null = Thêm, có giá trị = Sửa
  final CreateRecipeUseCase createUseCase;
  final UpdateRecipeUseCase updateUseCase;

  const RecipeFormPage({
    super.key,
    this.recipe,
    required this.createUseCase,
    required this.updateUseCase,
  });

  bool get isEditing => recipe != null;

  @override
  State<RecipeFormPage> createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  // 1. State
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _nameCtrl, _timeCtrl, _imageUrlCtrl, _videoUrlCtrl, _ingredientsCtrl, _stepsCtrl;
  String? _selectedCategory;

  // Lấy danh sách category (bỏ 'Tất cả')
  final List<String> _categoryOptions =
  categories.where((c) => c != 'Tất cả').toList();

  // 2. InitState
  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name);
    _timeCtrl = TextEditingController(text: r?.time.toString());
    _imageUrlCtrl = TextEditingController(text: r?.imageUrl);
    _videoUrlCtrl = TextEditingController(text: r?.videoUrl);
    _ingredientsCtrl = TextEditingController(text: r?.ingredients);
    _stepsCtrl = TextEditingController(text: r?.steps);
    _selectedCategory = r?.category;
  }

  // 3. Dispose
  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    _imageUrlCtrl.dispose();
    _videoUrlCtrl.dispose();
    _ingredientsCtrl.dispose();
    _stepsCtrl.dispose();
    super.dispose();
  }

  // 4. Hàm Save
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final recipeToSave = Recipe(
        id: widget.recipe?.id,
        name: _nameCtrl.text.trim(),
        category: _selectedCategory!,
        time: int.parse(_timeCtrl.text),
        imageUrl: _imageUrlCtrl.text.trim(),
        videoUrl: _videoUrlCtrl.text.trim(),
        ingredients: _ingredientsCtrl.text,
        steps: _stepsCtrl.text,
      );

      // Gọi UseCase tương ứng
      if (widget.isEditing) {
        await widget.updateUseCase.call(recipeToSave);
      } else {
        await widget.createUseCase.call(recipeToSave);
      }

      if (mounted) Navigator.pop(context, true); // Trả về true

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // 5. Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Sửa Công Thức' : 'Thêm Công Thức'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView( // Dùng ListView để tránh lỗi tràn màn hình
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTextFormField(_nameCtrl, 'Tên món ăn'),
            _buildGenreDropdown(),
            _buildTextFormField(
              _timeCtrl,
              'Thời gian nấu (phút)',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            _buildTextFormField(_imageUrlCtrl, 'Link ảnh (Image URL)'),
            _buildTextFormField(_videoUrlCtrl, 'Link video (Video URL) (Tùy chọn)', isRequired: false),
            _buildTextFormField(_ingredientsCtrl, 'Nguyên liệu', maxLines: 5),
            _buildTextFormField(_stepsCtrl, 'Các bước làm', maxLines: 8),
          ],
        ),
      ),
    );
  }

  // Helper build Text Field
  Widget _buildTextFormField(
      TextEditingController controller, String label,
      {bool isRequired = true, int? maxLines = 1, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), alignLabelWithHint: true),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return '$label không được để trống';
          }
          return null;
        },
      ),
    );
  }

  // Helper build Dropdown
  Widget _buildGenreDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: const InputDecoration(labelText: "Loại món", border: OutlineInputBorder()),
        items: _categoryOptions.map((String cat) {
          return DropdownMenuItem<String>(value: cat, child: Text(cat));
        }).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
        validator: (value) => (value == null) ? 'Vui lòng chọn loại món' : null,
      ),
    );
  }
}