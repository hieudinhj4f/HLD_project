import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test Dosage - Validation', () {
    bool validateDosage(String? dosage, int quantity) {
      if (quantity > 0) {
        return dosage != null && dosage.isNotEmpty && dosage.contains('/');
      }
      return true;
    }

    test('TC01 - Hợp lệ khi có quantity >0 và có dấu /', () {
      expect(validateDosage('Penicillin / 2 lần/ngày', 5), isTrue);
    });

    test('TC02 - Tùy chọn khi quantity = 0', () {
      expect(validateDosage('', 0), isTrue);
    });

    test('TC03 - Thiếu dấu / khi quantity >0', () {
      expect(validateDosage('Uống sáng tối', 5), isFalse);
    });

    test('TC04 - Rỗng khi quantity >0', () {
      expect(validateDosage('', 5), isFalse);
    });
  });
}