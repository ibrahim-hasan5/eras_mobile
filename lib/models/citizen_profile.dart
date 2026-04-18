class CitizenProfile {
  final int id;
  final String dateOfBirth;
  final String bloodGroup;
  final String phoneNumber;
  final String city;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String availableToDonate;

  CitizenProfile({
    required this.id,
    required this.dateOfBirth,
    required this.bloodGroup,
    required this.phoneNumber,
    required this.city,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.availableToDonate,
  });

  factory CitizenProfile.fromJson(Map<String, dynamic> json) {
    return CitizenProfile(
      id: json['id'] ?? 0,
      dateOfBirth: json['date_of_birth'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      city: json['city'] ?? '',
      emergencyContactName: json['emergency_contact_name'] ?? '',
      emergencyContactPhone: json['emergency_contact_phone'] ?? '',
      availableToDonate: json['available_to_donate'] ?? 'no',
    );
  }
}
