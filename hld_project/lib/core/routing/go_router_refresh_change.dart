import 'dart:async';
import 'package:flutter/foundation.dart';

/// ✅ Lớp này giúp GoRouter tự động cập nhật (refresh)
/// khi có sự thay đổi trạng thái đăng nhập Firebase (authStateChanges)
///
/// Ví dụ: Khi user logout → Router tự redirect về trang Login

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListener = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> notifyListener;

  @override
  void dispose() {
    notifyListener.cancel();
    super.dispose();
  }
}
