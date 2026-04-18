class DisasterResponse {
  final int id;
  final int disasterId;
  final String organizationName;
  final String serviceType;
  final String responseStatus;
  final String responseNotes;
  final String createdAt;

  DisasterResponse({
    required this.id,
    required this.disasterId,
    required this.organizationName,
    required this.serviceType,
    required this.responseStatus,
    required this.responseNotes,
    required this.createdAt,
  });

  factory DisasterResponse.fromJson(Map<String, dynamic> json) {
    return DisasterResponse(
      id: json['id'] ?? 0,
      disasterId: json['disaster'] ?? 0,
      organizationName: json['organization_name'] ?? '',
      serviceType: json['service_type'] ?? '',
      responseStatus: json['response_status'] ?? '',
      responseNotes: json['response_notes'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
