class DisasterAlert {
  final int id;
  final int disasterId;
  final String title;
  final String type;
  final String severity;
  final String location;
  final String matchType;
  final String sentAt;
  final bool isRead;

  DisasterAlert({
    required this.id,
    required this.disasterId,
    required this.title,
    required this.type,
    required this.severity,
    required this.location,
    required this.matchType,
    required this.sentAt,
    required this.isRead,
  });

  factory DisasterAlert.fromJson(Map<String, dynamic> json) {
    return DisasterAlert(
      id: json['id'] ?? 0,
      disasterId: json['disaster'] ?? 0,
      title: json['disaster_title'] ?? '',
      type: json['disaster_type'] ?? '',
      severity: json['severity'] ?? '',
      location: json['location'] ?? '',
      matchType: json['match_type'] ?? '',
      sentAt: json['sent_at'] ?? '',
      isRead: json['is_read'] ?? false,
    );
  }
}
