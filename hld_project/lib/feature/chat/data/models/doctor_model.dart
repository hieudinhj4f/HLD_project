import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor.dart';

class DoctorModel extends Doctor {
  DoctorModel({
    required super.id,
    required super.name,
    required super.specialty,
    required super.degree,
    required super.type,
    required super.experienceYears,
    required super.imageUrl,
    required super.totalExaminations,
    required super.accurateRate,
    required super.averageRating,
    required super.totalReviews,
    required super.totalConsultations,
    required super.onlineHours,
    required super.responseRate,
    required super.activeDays,
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      degree: data['degree'] ?? '',
      type: data['type'] ?? '',
      experienceYears: (data['experienceYears'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      totalExaminations: (data['totalExaminations'] as num?)?.toInt() ?? 0,
      accurateRate: (data['accurateRate'] as num?)?.toDouble() ?? 0.0,
      averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (data['totalReviews'] as num?)?.toInt() ?? 0,
      totalConsultations: (data['totalConsultations'] as num?)?.toInt() ?? 0,
      onlineHours: (data['onlineHours'] as num?)?.toInt() ?? 0,
      responseRate: (data['responseRate'] as num?)?.toDouble() ?? 0.0,
      activeDays: (data['activeDays'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name': name,
    'specialty': specialty,
    'degree': degree,
    'type': type,
    'experienceYears': experienceYears,
    'imageUrl': imageUrl,
    'totalExaminations': totalExaminations,
    'accurateRate': accurateRate,
    'averageRating': averageRating,
    'totalReviews': totalReviews,
    'totalConsultations': totalConsultations,
    'onlineHours': onlineHours,
    'responseRate': responseRate,
    'activeDays': activeDays,
  };

  Doctor toEntity() {
    return Doctor(
      id: id,
      name: name,
      specialty: specialty,
      degree: degree,
      type: type,
      experienceYears: experienceYears,
      imageUrl: imageUrl,
      totalExaminations: totalExaminations,
      accurateRate: accurateRate,
      averageRating: averageRating,
      totalReviews: totalReviews,
      totalConsultations: totalConsultations,
      onlineHours: onlineHours,
      responseRate: responseRate,
      activeDays: activeDays,
    );
  }

  factory DoctorModel.fromEntity(Doctor doctor) {
    return DoctorModel(
      id: doctor.id,
      name: doctor.name,
      specialty: doctor.specialty,
      degree: doctor.degree,
      type: doctor.type,
      experienceYears: doctor.experienceYears,
      imageUrl: doctor.imageUrl,
      totalExaminations: doctor.totalExaminations,
      accurateRate: doctor.accurateRate,
      averageRating: doctor.averageRating,
      totalReviews: doctor.totalReviews,
      totalConsultations: doctor.totalConsultations,
      onlineHours: doctor.onlineHours,
      responseRate: doctor.responseRate,
      activeDays: doctor.activeDays,
    );
  }
}