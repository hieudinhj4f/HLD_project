
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String degree;
  final String type;
  final int experienceYears;
  final String imageUrl;
  final int totalExaminations;
  final double accurateRate;
  final double averageRating;
  final int totalReviews;
  final int totalConsultations;
  final int onlineHours;
  final double responseRate;
  final int activeDays;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.degree,
    required this.type,
    required this.experienceYears,
    required this.imageUrl,
    required this.totalExaminations,
    required this.accurateRate,
    required this.averageRating,
    required this.totalReviews,
    required this.totalConsultations,
    required this.onlineHours,
    required this.responseRate,
    required this.activeDays,
  });
}