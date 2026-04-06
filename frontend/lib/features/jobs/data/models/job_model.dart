enum JobType { internship, fullTime, partTime }

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final JobType type;
  final String postedAgo;
  final String description;
  final List<String> requirements;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.postedAgo,
    required this.description,
    this.requirements = const [],
  });

  String get typeLabel => switch (type) {
        JobType.internship => 'Práctica',
        JobType.fullTime => 'Tiempo completo',
        JobType.partTime => 'Medio tiempo',
      };
}
