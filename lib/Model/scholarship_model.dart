class ScholarshipModel {
  final String id;
  final String title;
  final String link;
  final String location;
  final String fundingType;
  final String gender;
  final String deadline;
  final List<String> degree;
  final List<String> nationality;
  final List<String> fieldsOfStudy;
  final List<String> criteria;
  final List<String> benefits;

  ScholarshipModel({
    required this.id,
    required this.title,
    required this.link,
    required this.location,
    required this.fundingType,
    required this.gender,
    required this.deadline,
    required this.degree,
    required this.nationality,
    required this.fieldsOfStudy,
    required this.criteria,
    required this.benefits,
  });

  factory ScholarshipModel.fromJson(Map<String, dynamic> json) {
    return ScholarshipModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      location: json['location'] ?? '',
      fundingType: json['fundingType'] ?? '',
      gender: json['gender'] ?? '',
      deadline: json['deadline'] ?? '',
      degree: List<String>.from(json['degree'] ?? []),
      nationality: List<String>.from(json['nationality'] ?? []),
      fieldsOfStudy: List<String>.from(json['fieldsOfStudy'] ?? []),
      criteria: List<String>.from(json['criteria'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }
}
