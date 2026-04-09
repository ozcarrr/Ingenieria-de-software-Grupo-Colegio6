enum OpportunityType { practice, job }

extension OpportunityTypeLabel on OpportunityType {
  String get label {
    switch (this) {
      case OpportunityType.practice:
        return 'Practica';
      case OpportunityType.job:
        return 'Trabajo';
    }
  }
}

class JobModel {
  const JobModel({
    required this.id,
    required this.company,
    required this.title,
    required this.location,
    required this.type,
    required this.description,
    required this.skills,
    required this.logoUrl,
    required this.postedDate,
    this.salary,
    this.specializations = const [],
  });

  final String id;
  final String company;
  final String title;
  final String location;
  final OpportunityType type;
  final String description;
  final List<String> skills;
  final String logoUrl;
  final String postedDate;
  final String? salary;
  final List<String> specializations;
}
