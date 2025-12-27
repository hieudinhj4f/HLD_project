// test/patient_id_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test PatientID - Validation', () {
    bool validatePatientId(String patientId) {
      if (patientId.isEmpty) return false;
      return RegExp(r'^PAT-\d{3,}$').hasMatch(patientId);
    }

    test('TC01 - Hợp lệ: Định dạng PAT- theo sau là số', () {
      expect(validatePatientId('PAT-001'), isTrue);
      expect(validatePatientId('PAT-12345'), isTrue);
    });

    test('TC02 - Thiếu gạch ngang', () {
      expect(validatePatientId('PAT001'), isFalse);
    });

    test('TC03 - Sai định dạng hoàn toàn', () {
      expect(validatePatientId('ABC-123'), isFalse);
    });

    test('TC04 - Rỗng hoặc null', () {
      expect(validatePatientId(''), isFalse);
    });
  });
}