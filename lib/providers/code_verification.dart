import 'package:cambio_veraz/models/code_verification.dart';
import 'package:cambio_veraz/services/firestore.dart';
import 'package:flutter/foundation.dart';

class CodeVerificationProvider extends ChangeNotifier {
  CodeVerificationProvider() {
    getCode();
  }

  List<CodeVerification> _code = [];

  bool _loading = false;

  List<CodeVerification> get codes => _code;
  bool get loading => _loading;

  set codes(List<CodeVerification> codes) {
    _code = codes;
    notifyListeners();
  }

  getCode() async {
    _loading = true;
    notifyListeners();

    database.code.listen((event) async {
      _code = event;
      _loading = false;
      notifyListeners();
    });
  }
}
