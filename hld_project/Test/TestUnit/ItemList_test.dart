// test/item_list_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test ItemList - Validation', () {
    bool validateItemList(List<Map<String, dynamic>> items) {
      if (items.isEmpty) return false;
      for (var item in items) {
        if (item['drugID'] == null || item['quantity'] == null) return false;
      }
      return true;
    }

    test('TC01 - Hợp lệ: Có ít nhất 1 thuốc với drugID và quantity', () {
      expect(validateItemList([{'drugID': 'PEN-001', 'quantity': 5}]), isTrue);
    });

    test('TC02 - Danh sách rỗng', () {
      expect(validateItemList([]), isFalse);
    });

    test('TC03 - Thiếu trường bắt buộc', () {
      expect(validateItemList([{'drugID': 'PEN-001'}]), isFalse);
    });
  });
}