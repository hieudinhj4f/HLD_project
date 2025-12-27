// test/prescription_date_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test PrescriptionDate - Validation', () {
    bool validatePrescriptionDate(String dateStr, String prescriptionId) {
      try {
        DateTime date = DateTime.parse(dateStr);

        // Không được là ngày tương lai (so với ngày hiện tại: 25/12/2025)
        DateTime now = DateTime(2025, 12, 25);
        if (date.isAfter(now)) return false;

        // Phải khớp với phần YYYYMMDD trong prescriptionId
        String expectedDatePart = prescriptionId.toUpperCase().substring(3, 11);
        String actualDatePart =
            '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

        return actualDatePart == expectedDatePart;
      } catch (e) {
        return false; // Sai định dạng hoặc ngày không tồn tại
      }
    }

    test('TC01 - Hợp lệ: Ngày đúng định dạng và khớp với ID', () {
      expect(validatePrescriptionDate('2025-12-25', 'RX-20251225-TEST0001'), isTrue);
    });

    test('TC02 - Ngày tương lai không được phép', () {
      expect(validatePrescriptionDate('2026-01-01', 'RX-20260101-TEST0001'), isFalse);
    });

    test('TC03 - Ngày không tồn tại (30/02)', () {
      expect(validatePrescriptionDate('2025-02-30', 'RX-20250230-TEST0001'), isFalse);
    });

    test('TC04 - Ngày không khớp với phần ngày trong ID', () {
      expect(validatePrescriptionDate('2025-12-26', 'RX-20251225-TEST0001'), isFalse);
    });

    test('TC05 - Sai định dạng ngày (DD/MM/YYYY)', () {
      expect(validatePrescriptionDate('25/12/2025', 'RX-20251225-TEST0001'), isFalse);
    });
  });
}