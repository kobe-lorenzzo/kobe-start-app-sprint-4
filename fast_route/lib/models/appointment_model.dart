import "package:cloud_firestore/cloud_firestore.dart";

class AppointmentModel {
  final String id;
  final String userId;
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime dateTime;

  AppointmentModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.dateTime,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AppointmentModel(
      id: documentId, 
      userId: map['userId'] ?? '', 
      title: map['title'] ?? '', 
      address: map['address'] ?? '', 
      latitude: (map['latitude'] as num).toDouble(), 
      longitude: (map['longitude'] as num).toDouble(),
      dateTime: (map['dateTime'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}