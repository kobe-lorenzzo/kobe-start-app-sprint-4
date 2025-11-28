import 'package:fast_route/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firestore_service.dart';
import '../../../models/appointment_model.dart';

class AgendaProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;

  AgendaProvider(this._firestoreService, this._notificationService);

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

  Future<bool> updateAppointment(AppointmentModel appointment) async {
    _setLoading(true);
    try {
      await _firestoreService.updateAppointment(appointment);
      _setLoading(false); // Corrigido para false ao terminar
      return true;
    } catch (e) {
      _setError("Erro ao atualizar card: $e");
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteAppointment(String appointmentId) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteAppointment(appointmentId);
    } catch (e) {
      _setError("Erro ao deletar card: $e");
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

  Future<void> checkTimeLeft(AppointmentModel appointment) async {
    final now = DateTime.now();
    final difference = appointment.dateTime.difference(now);
    
    String title = "Status: ${appointment.title}";
    String body;

    if (difference.isNegative) {
      final minutesPast = difference.abs().inMinutes;
      if (minutesPast < 60) {
         body = "Este compromisso já passou há $minutesPast minutos.";
      } else {
         body = "Este compromisso já passou há ${difference.abs().inHours} horas.";
      }
    } else {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;

      if (days > 0) {
        body = "Faltam $days dias, $hours horas e $minutes minutos.";
      } else if (hours > 0) {
        body = "Faltam $hours horas e $minutes minutos.";
      } else {
        body = "É logo ali! Faltam apenas $minutes minutos.";
      }
    }

    final notificationId = appointment.id.hashCode; 

    await _notificationService.showImmediateNotification(
      id: notificationId,
      title: title,
      body: body,
    );
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