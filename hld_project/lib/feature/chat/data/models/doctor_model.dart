import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  DoctorModel({
    required super.id,
    required super.name,
    required super.specialty,
    required super.degree,
    required super.imageUrl,
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      degree: data['degree'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'specialty': specialty,
        'degree': degree,
        'imageUrl': imageUrl,
      };
}