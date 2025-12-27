// test/quantity_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test Quantity - Validation', () {
    bool validateQuantity(int quantity, int stock) {
      return quantity > 0 && quantity <= stock;
    }

    test('TC01 - Hợp lệ: Số lượng >0 và ≤ tồn kho', () {
      expect(validateQuantity(5, 10), isTrue);
    });

    test('TC02 - Bằng 0', () {
      expect(validateQuantity(0, 10), isFalse);
    });

    test('TC03 - Âm', () {
      expect(validateQuantity(-3, 10), isFalse);
    });

    test('TC04 - Vượt tồn kho', () {
      expect(validateQuantity(15, 10), isFalse);
    });
  });
}