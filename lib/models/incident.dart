class IncidentData {
  final String id;
  final String title;
  final String service;
  final String severity;
  final String age;
  /// OPEN | IN_PROGRESS | RESOLVED (ops workflow)
  final String status;

  IncidentData({
    required this.id,
    required this.title,
    required this.service,
    required this.severity,
    required this.age,
    this.status = 'OPEN',
  });

  IncidentData copyWith({
    String? id,
    String? title,
    String? service,
    String? severity,
    String? age,
    String? status,
  }) {
    return IncidentData(
      id: id ?? this.id,
      title: title ?? this.title,
      service: service ?? this.service,
      severity: severity ?? this.severity,
      age: age ?? this.age,
      status: status ?? this.status,
    );
  }
}
