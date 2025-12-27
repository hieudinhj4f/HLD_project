import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TestPrescriptionID - Validation', () {
    // Hàm validation chính
    bool validatePrescriptionId(String prescriptionId, String prescriptionDateStr) {
      if (prescriptionId is! String || prescriptionDateStr is! String) {
        return false;
      }

      String upperId = prescriptionId.toUpperCase();

      RegExp regex = RegExp(r'^RX-\d{8}-[A-Z0-9]{8}$');
      if (!regex.hasMatch(upperId)) {
        return false;
      }

      String datePart = upperId.substring(3, 11);

      // Kiểm tra ngày trong ID có hợp lệ không
      try {
        DateTime.parse('${datePart.substring(0, 4)}-${datePart.substring(4, 6)}-${datePart.substring(6, 8)}');
      } catch (e) {
        return false;
      }

      // Kiểm tra ngày đầu vào có đúng định dạng và khớp với datePart không
      try {
        DateTime inputDate = DateTime.parse(prescriptionDateStr);
        String formattedInputDate =
            '${inputDate.year.toString().padLeft(4, '0')}${inputDate.month.toString().padLeft(2, '0')}${inputDate.day.toString().padLeft(2, '0')}';

        if (formattedInputDate != datePart) {
          return false;
        }
      } catch (e) {
        return false;
      }

      return true;
    }

    // ===================================================================
    // TEST CASE 1: Hợp lệ - Định dạng chuẩn và ngày khớp hoàn toàn
    // Trạng thái mong đợi: PASS (isTrue)
    // ===================================================================
    test('TC01 - Hợp lệ: Định dạng đúng RX-YYYYMMDD-XXXXXXXX và ngày khớp', () {
      expect(validatePrescriptionId('RX-20251225-TEST0001', '2025-12-25'), isTrue);
      expect(validatePrescriptionId('rx-20251225-test0001', '2025-12-25'), isTrue); // Không phân biệt hoa/thường
    });

    // ===================================================================
    // TEST CASE 2: Sai tiền tố (không phải RX-)
    // Trạng thái mong đợi: FAIL (isFalse)
    // ===================================================================
    test('TC02 - Sai tiền tố: Không bắt đầu bằng RX-', () {
      expect(validatePrescriptionId('TX-20251225-0001', '2025-12-25'), isFalse);
    });

    // ===================================================================
    // TEST CASE 3: Ngày trong ID không khớp với PrescriptionDate
    // Trạng thái mong đợi: FAIL (isFalse)
    // ===================================================================
    test('TC03 - Ngày trong ID không khớp với ngày đầu vào', () {
      expect(validatePrescriptionId('RX-20241225-0001', '2025-12-25'), isFalse);
    });

    // ===================================================================
    // TEST CASE 4: Phần đuôi không đủ 8 ký tự
    // Trạng thái mong đợi: FAIL (isFalse)
    // ===================================================================
    test('TC04 - Phần đuôi sau ngày không đủ 8 ký tự alphanumeric', () {
      expect(validatePrescriptionId('RX-20251225-TEST000', '2025-12-25'), isFalse); // Chỉ có 7 ký tự
    });

    // ===================================================================
    // TEST CASE 5: Phần ngày trong ID chứa ký tự không phải số
    // Trạng thái mong đợi: FAIL (isFalse)
    // ===================================================================
    test('TC05 - Phần ngày trong ID chứa ký tự không hợp lệ (không phải số)', () {
      expect(validatePrescriptionId('RX-2025122A-TEST0001', '2025-12-25'), isFalse);
    });

    // ===================================================================
    // TEST CASE 6: Ngày không tồn tại trong lịch (ví dụ 30/02)
    // Trạng thái mong đợi: FAIL (isFalse)
    // ===================================================================
    test('TC06 - Ngày trong ID không tồn tại (ví dụ: 30 tháng 2)', () {
      expect(validatePrescriptionId('RX-20250230-TEST0001', '2025-02-30'), isFalse);
    });

    // ===================================================================
    // TEST CASE 7: Định dạng PrescriptionDate đầu vào sai
    // Trạng thái mong đợi: FAIL (isFalse)
    // ===================================================================
    test('TC07 - PrescriptionDate đầu vào sai định dạng (không phải YYYY-MM-DD)', () {
      expect(validatePrescriptionId('RX-20251225-TEST0001', '25/12/2025'), isFalse);
      expect(validatePrescriptionId('RX-20251225-TEST0001', '2025-13-01'), isFalse); // Tháng 13 không tồn tại
    });
  });
}