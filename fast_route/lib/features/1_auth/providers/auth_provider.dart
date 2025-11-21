import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthProvider(this._authService, this._firestoreService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _user;
  User? get user => _user;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    clearError();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        _user = user;
        _setLoading(false);

        return true;
      } else {
        _setError("email ou senha inválidos.");
        _setLoading(false);

        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);

      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    clearError();

    try {
      final user = await _authService.createUserWithEmailAndPassword(email, password);

      if (user != null) {
        _user = user;

        await _firestoreService.saveUser(user);

        _setLoading(false);
        return true;
      } else {
        _setError("Não foi possível criar a conta.");
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
