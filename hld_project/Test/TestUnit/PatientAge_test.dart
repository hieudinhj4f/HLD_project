// test/patient_age_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test PatientAge - Validation', () {
    bool validatePatientAge(int age, {String? drugType}) {
      if (age <= 0 || age >= 120) return false;

      if (drugType == 'Pediatric' && age >= 16) return false;
      if (drugType == 'PenicillinHigh' && age < 18) return false;

      return true;
    }

    test('TC01 - Tuổi người lớn bình thường', () {
      expect(validatePatientAge(30), isTrue);
    });

    test('TC02 - Đơn nhi hợp lệ (dưới 16 tuổi)', () {
      expect(validatePatientAge(10, drugType: 'Pediatric'), isTrue);
    });

    test('TC03 - Thuốc liều cao hợp lệ (trên 18 tuổi)', () {
      expect(validatePatientAge(25, drugType: 'PenicillinHigh'), isTrue);
    });

    test('TC04 - Tuổi âm hoặc quá giới hạn', () {
      expect(validatePatientAge(-5), isFalse);
      expect(validatePatientAge(150), isFalse);
    });

    test('TC05 - Tuổi nhỏ dùng thuốc liều cao', () {
      expect(validatePatientAge(15, drugType: 'PenicillinHigh'), isFalse);
    });

    test('TC06 - Tuổi lớn dùng đơn nhi', () {
      expect(validatePatientAge(20, drugType: 'Pediatric'), isFalse);
    });
  });
}