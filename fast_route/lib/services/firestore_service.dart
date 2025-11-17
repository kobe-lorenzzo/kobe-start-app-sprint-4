import 'package:cloud_firestore/cloud_firestore.dart';
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
}