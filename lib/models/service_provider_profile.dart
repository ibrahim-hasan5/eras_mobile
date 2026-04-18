class ServiceProviderProfile {
  final int id;
  final String organizationName;
  final String serviceType;
  final String email;
  final String contactNumber;
  final String city;
  final int currentCapacity;
  final int maximumCapacity;
  final String currentStatus;

  ServiceProviderProfile({
    required this.id,
    required this.organizationName,
    required this.serviceType,
    required this.email,
    required this.contactNumber,
    required this.city,
    required this.currentCapacity,
    required this.maximumCapacity,
    required this.currentStatus,
  });

  factory ServiceProviderProfile.fromJson(Map<String, dynamic> json) {
    return ServiceProviderProfile(
      id: json['id'] ?? 0,
      organizationName: json['organization_name'] ?? '',
      serviceType: json['service_type'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      city: json['city'] ?? '',
      currentCapacity: json['current_capacity'] ?? 0,
      maximumCapacity: json['maximum_capacity'] ?? 0,
      currentStatus: json['current_status'] ?? 'active',
    );
  }
}
