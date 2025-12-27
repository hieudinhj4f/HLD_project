// test/patient_gender_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test PatientGender - Validation', () {
    bool validatePatientGender(String gender) {
      return {'Nam', 'Nữ', 'Khác'}.contains(gender);
    }

    test('TC01 - Giới tính hợp lệ: Nam', () {
      expect(validatePatientGender('Nam'), isTrue);
    });

    test('TC02 - Giới tính hợp lệ: Nữ', () {
      expect(validatePatientGender('Nữ'), isTrue);
    });

    test('TC03 - Giới tính hợp lệ: Khác', () {
      expect(validatePatientGender('Khác'), isTrue);
    });

    test('TC04 - Sai giá trị (tiếng Anh)', () {
      expect(validatePatientGender('Male'), isFalse);
    });

    test('TC05 - Rỗng hoặc null', () {
      expect(validatePatientGender(''), isFalse);
    });
  });
}