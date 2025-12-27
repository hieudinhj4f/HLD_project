import 'package:intl/intl.dart'; // Để format ngày nếu cần

class PrescriptionValidator {
  /// 1. Kiểm tra PrescriptionID
  /// Định dạng: RX-YYYYMMDD-XXXXXXXX (8 ký tự alphanumeric ở đuôi)
  /// Phần ngày phải hợp lệ và khớp chính xác với prescriptionDate (YYYY-MM-DD)
  static bool validatePrescriptionId(
      String prescriptionId, String prescriptionDateStr) {
    // Kiểm tra kiểu dữ liệu
    if (prescriptionId is! String || prescriptionDateStr is! String) {
      return false;
    }

    String upperId = prescriptionId.toUpperCase();

    // Regex kiểm tra định dạng chính xác
    RegExp regex = RegExp(r'^RX-\d{8}-[A-Z0-9]{8}$');
    if (!regex.hasMatch(upperId)) {
      return false;
    }

    // Trích phần ngày từ ID
    String datePart = upperId.substring(3, 11);

    // Kiểm tra ngày trong ID có hợp lệ không (YYYY-MM-DD)
    DateTime? idDate;
    try {
      idDate = DateTime.parse('${datePart.substring(0, 4)}-${datePart.substring(4, 6)}-${datePart.substring(6, 8)}');
    } catch (e) {
      return false; // Ngày không tồn tại (ví dụ 30/02)
    }

    // Kiểm tra prescriptionDateStr có đúng định dạng và khớp với datePart
    DateTime? inputDate;
    try {
      inputDate = DateTime.parse(prescriptionDateStr);
    } catch (e) {
      return false; // Sai định dạng YYYY-MM-DD
    }

    String formattedInputDate =
        '${inputDate.year.toString().padLeft(4, '0')}${inputDate.month.toString().padLeft(2, '0')}${inputDate.day.toString().padLeft(2, '0')}';

    if (formattedInputDate != datePart) {
      return false;
    }

    // Không cho phép ngày tương lai (so với ngày hiện tại: 25/12/2025)
    DateTime now = DateTime(2025, 12, 25);
    if (inputDate.isAfter(now)) {
      return false;
    }

    return true;
  }

  /// 2. Kiểm tra PatientID (giả định định dạng PAT-XXX hoặc tương tự)
  static bool validatePatientId(String patientId) {
    if (patientId is! String || patientId.isEmpty) {
      return false;
    }
    // Ví dụ định dạng: PAT- followed by digits
    return RegExp(r'^PAT-\d{3,}$').hasMatch(patientId);
  }

  /// 3. Kiểm tra PatientAge
  static bool validatePatientAge(int age, {String? drugType}) {
    if (age <= 0 || age >= 120) {
      return false;
    }

    if (drugType == 'Pediatric' && age >= 16) {
      return false; // Đơn nhi chỉ dành cho < 16 tuổi
    }
    if (drugType == 'PenicillinHigh' && age < 18) {
      return false; // Thuốc liều cao yêu cầu >= 18
    }

    return true;
  }

  /// 4. Kiểm tra PatientGender
  static bool validatePatientGender(String gender) {
    const validGenders = {'Nam', 'Nữ', 'Khác'};
    return validGenders.contains(gender);
  }

  /// 5. Kiểm tra ItemList (danh sách thuốc)
  static bool validateItemList(List<Map<String, dynamic>> itemList) {
    if (itemList.isEmpty) {
      return false;
    }
    for (var item in itemList) {
      if (item['drugID'] == null || item['quantity'] == null) {
        return false;
      }
    }
    return true;
  }

  /// 6. Kiểm tra drugID trong mỗi item
  static bool validateDrugId(String drugId) {
    if (drugId.isEmpty || drugId.length > 40) {
      return false;
    }
    // Định dạng ví dụ: LOAITHUOC-MASO
    return RegExp(r'^[A-Z]+-\d+$').hasMatch(drugId);
  }

  /// 7. Kiểm tra quantity trong mỗi item
  static bool validateQuantity(int quantity, int stock) {
    return quantity > 0 && quantity <= stock;
  }

  /// 8. Kiểm tra Dosage
  static bool validateDosage(String? dosage, int quantity) {
    if (quantity > 0) {
      return dosage != null && dosage.isNotEmpty && dosage.contains('/');
    }
    return true; // Tùy chọn khi quantity = 0
  }

  /// 9. Kiểm tra SpecialNote
  static bool validateSpecialNote(String? note, {bool hasAllergy = false}) {
    if (note == null) {
      return !hasAllergy; // Nếu có dị ứng thì phải có ghi chú
    }
    if (hasAllergy && note.trim().isEmpty) {
      return false;
    }
    return true;
  }
}