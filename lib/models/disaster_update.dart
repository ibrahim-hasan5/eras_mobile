class DisasterUpdate {
  final int id;
  final String type;
  final String updatedByName;
  final String notes;
  final String createdAt;

  DisasterUpdate({
    required this.id,
    required this.type,
    required this.updatedByName,
    required this.notes,
    required this.createdAt,
  });

  factory DisasterUpdate.fromJson(Map<String, dynamic> json) {
    return DisasterUpdate(
      id: json['id'] ?? 0,
      type: json['update_type'] ?? '',
      updatedByName: json['updated_by_name'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
