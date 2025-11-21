import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_route/models/appointment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    try {
      await _db.collection("users").doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Erro ao salvar usuário no Firestoe: $e");
      throw e;
    }
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      await _db.collection("appointments").doc(appointment.id).set(
        appointment.toMap(),
      );
    } catch (e) {
      print("Erro ao criar compromisso: $e");
      throw e;
    }
  }

  Stream<List<AppointmentModel>> getAppointmentsStream(String userId) {
    return _db
      .collection('appointments')
      .where('userId', isEqualTo: userId)
      .orderBy('dateTime')
      .snapshots()
      .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AppointmentModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<void> updateAppointment (AppointmentModel appointment) async {
    try {
      await _db.collection("appointments").doc(appointment.id).update(
        appointment.toMap()
      );
    } catch (e) {
      print("Erro ao atualizar card: $e");
      throw e;
    }
  }

  Future<void> deleteAppointment (String appointmentId) async {
    try {
      await _db.collection("appointment").doc(appointmentId).delete();
    } catch (e) {
      print("Erro ao deletar card: $e");
      throw e;
    }
  }
}