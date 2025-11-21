import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore_service.dart';
import '../../../services/geocoding_service.dart';
import '../../../models/appointment_model.dart';

class AgendaProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  AgendaProvider(this._firestoreService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> createAppointment({
    required String title,
    required String address,
    required DateTime date,
    required TimeOfDay time,
    required double latitude,
    required double longitude,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setError("Usuário não autenticado.");
        _setLoading(false);
        return false;
      }

      final DateTime fullDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

      final newAppointment = AppointmentModel(
        id: uniqueId,
        userId: user.uid,
        title: title,
        address: address,
        latitude: latitude,
        longitude: longitude,
        dateTime: fullDateTime,
      );

      await _firestoreService.addAppointment(newAppointment);

      _setLoading(false);
      return true;

    } catch (e) {
      _setError("Erro ao criar compromisso: $e");
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateAppointment (AppointmentModel appointment) async {
    _setLoading(true);
    try {
      await _firestoreService.updateAppointment(appointment);
      _setLoading(true);
      return true;
    } catch (e) {
      _setError("Erro ao atualizar cards: $e");
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteAppointment (String appointmentId) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteAppointment(appointmentId);
    } catch (e) {
      _setError("Erro ao deletar dard: $e");
    } finally {
      _setLoading(false);
    }
  }

  Stream<List<AppointmentModel>> get myAppointmentsStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return _firestoreService.getAppointmentsStream(user.uid);
    } else {

      return Stream.value([]); 
    }
  }

  // --- Helpers ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }


}
