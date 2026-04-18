class BloodRequest {
  final int id;
  final String requesterName;
  final String patientName;
  final String bloodTypeNeeded;
  final int bagsNeeded;
  final String location;
  final String contactPhone;
  final String urgency;
  final String neededByDate;
  final String additionalNotes;
  final String status;
  final String requesterCity;

  BloodRequest({
    required this.id,
    required this.requesterName,
    required this.patientName,
    required this.bloodTypeNeeded,
    required this.bagsNeeded,
    required this.location,
    required this.contactPhone,
    required this.urgency,
    required this.neededByDate,
    required this.additionalNotes,
    required this.status,
    required this.requesterCity,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: json['id'] ?? 0,
      requesterName: json['requester_name'] ?? '',
      patientName: json['patient_name'] ?? '',
      bloodTypeNeeded: json['blood_type_needed'] ?? '',
      bagsNeeded: json['bags_needed'] ?? 1,
      location: json['location'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      urgency: json['urgency'] ?? 'normal',
      neededByDate: json['needed_by_date'] ?? '',
      additionalNotes: json['additional_notes'] ?? '',
      status: json['status'] ?? 'open',
      requesterCity: json['requester_city'] ?? '',
    );
  }
}
