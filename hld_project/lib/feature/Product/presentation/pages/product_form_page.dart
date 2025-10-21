import 'package:flutter/material.dart';
// Chỉ cần import 'cloud_firestore.dart' là đủ cho cả mobile và web
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entity/product/product.dart';
import '../../domain/usecase/createProduct.dart';
import '../../domain/usecase/updateProduct.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product; // Product (có thể null) được truyền vào để chỉnh sửa
  final CreateProduct createUseCase;
  final UpdateProduct updateUseCase;

  const ProductFormPage({
    super.key,
    this.product,
    required this.createUseCase,
    required this.updateUseCase,
  });

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  // 1. STATE VARIABLES (Biến trạng thái)

  // Key này dùng để theo dõi và xác thực (validate) Form
  final _formKey = GlobalKey<FormState>();

  // Controllers để "kiểm soát" các trường văn bản
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageUrlController;
  // === FIX: Thêm các controller còn thiếu ===
  late TextEditingController _descriptionController;
  late TextEditingController _categoriesController;
  // (categoryId sẽ tốt hơn, nhưng dùng categories (String) theo code của bạn)

  // Biến trạng thái cho việc tải
  bool _isSaving = false;

  // 2. INIT STATE (Khởi tạo)
  @override
  void initState() {
    super.initState();
    // Xác định xem đây là form 'Chỉnh sửa' (true) hay 'Tạo mới' (false)
    final isEditing = widget.product != null;
    final product = widget.product; // Lấy product ra cho gọn

    // === FIX: Khởi tạo TẤT CẢ các controller ===
    // Nếu là 'Chỉnh sửa', gán giá trị cũ. Nếu 'Tạo mới', gán chuỗi rỗng.
    _nameController = TextEditingController(text: isEditing ? product!.name : '');
    _priceController = TextEditingController(text: isEditing ? product!.price.toString() : '');
    _quantityController = TextEditingController(text: isEditing ? product!.quantity.toString() : '');
    _imageUrlController = TextEditingController(text: isEditing ? product!.imageUrl : '');
    _descriptionController = TextEditingController(text: isEditing ? product!.description : '');
    _categoriesController = TextEditingController(text: isEditing ? product!.categories : '');

    // 2 biến Timestamp bạn khai báo không cần thiết phải là state variable,
    // vì chúng được đặt giá trị lúc LƯU, không phải do người dùng nhập.
    // Chúng ta sẽ xử lý chúng trong hàm _saveForm().
  }

  // 3. DISPOSE (Dọn dẹp)
  @override
  void dispose() {
    // === FIX: Dọn dẹp TẤT CẢ controller để tránh rò rỉ bộ nhớ ===
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  // 4. LOGIC LƯU FORM
  Future<void> _saveForm() async {
    // 4.1. Validate form
    // Nếu form không hợp lệ (ví dụ: thiếu tên), thì dừng lại.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 4.2. Bật trạng thái loading
    setState(() {
      _isSaving = true;
    });

    try {
      // 4.3. Lấy thời gian hiện tại
      // Dùng cho 'createAt' (nếu tạo mới) và 'updateAt' (luôn luôn)
      final now = Timestamp.now();

      // 4.4. Tạo đối tượng Product
      // === FIX: Giả định Model Product của bạn có TẤT CẢ các trường này ===
      final productToSave = Product(
        // ID: Nếu là chỉnh sửa, dùng ID cũ.
        // Nếu là tạo mới, dùng ID rỗng (hoặc null) để useCase/repository tự tạo.
        id: widget.product?.id ?? '',
        name: _nameController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
        imageUrl: _imageUrlController.text,
        // === FIX: Lấy giá trị từ controller thay vì chuỗi rỗng ===
        description: _descriptionController.text,
        categories: _categoriesController.text,

        // === FIX: Xử lý logic Timestamp ===
        // createAt: Nếu là chỉnh sửa, giữ nguyên giá trị cũ.
        //             Nếu là tạo mới (widget.product là null), gán 'now'.
        createdAt: widget.product?.createdAt ?? now,

        // updateAt: Luôn luôn gán là 'now' mỗi khi lưu.
        updateAt: now,
      );

      // 4.5. Gọi UseCase
      if (widget.product == null) {
        // Tình huống 1: THÊM MỚI
        await widget.createUseCase.call(productToSave);
      } else {
        // Tình huống 2: CHỈNH SỬA
        await widget.updateUseCase.call(productToSave);
      }

      // 4.6. Đóng form nếu thành công
      // Trả về 'true' để báo cho trang trước (ProductListPage) biết cần tải lại danh sách
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      // 4.7. Xử lý lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu dữ liệu: $e')),
        );
      }
    } finally {
      // 4.8. Tắt trạng thái loading (dù thành công hay thất bại)
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 5. BUILD (Xây dựng UI)
  @override
  Widget build(BuildContext context) {
    // Lấy lại biến này cho dễ đọc
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Chỉnh Sửa Sản Phẩm' : 'Thêm Sản Phẩm Mới'),
        actions: [
          // Nút Save với trạng thái loading
          IconButton(
            icon: _isSaving
                ? const SizedBox( // Hiển thị vòng xoay nếu đang lưu
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
            )
                : const Icon(Icons.save), // Hiển thị icon save
            // Vô hiệu hóa nút khi đang lưu
            onPressed: _isSaving ? null : _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Gắn key vào Form
          child: ListView( // Dùng ListView để tránh lỗi tràn màn hình khi bàn phím hiện lên
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên Sản Phẩm'),
                validator: (value) { // Logic kiểm tra
                  if (value == null || value.isEmpty) return 'Vui lòng nhập tên sản phẩm.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number, // Bàn phím số
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) return 'Vui lòng nhập giá hợp lệ.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) return 'Vui lòng nhập số lượng hợp lệ.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Hình ảnh'),
                // Không bắt buộc nên không cần validator
              ),
              const SizedBox(height: 16),

              // === FIX: Thêm các trường UI còn thiếu ===
              TextFormField(
                controller: _categoriesController,
                decoration: const InputDecoration(labelText: 'Danh mục (ID)'),
                // (Sau này bạn nên đổi thành DropdownButton để chọn)
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả', alignLabelWithHint: true),
                maxLines: 3, // Cho phép nhập nhiều dòng
              ),
            ],
          ),
        ),
      ),
    );
  }
}