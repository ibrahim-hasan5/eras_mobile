import 'package:flutter/material.dart';

class DisasterImage {
  final int id;
  final String image;
  final String? caption;

  DisasterImage({required this.id, required this.image, this.caption});

  factory DisasterImage.fromJson(Map<String, dynamic> json) {
    return DisasterImage(
      id: json['id'],
      image: json['image'],
      caption: json['caption'],
    );
  }
}

class Disaster {
  final int id;
  final String title;
  final String disasterType;
  final String city;
  final String areaSector;
  final String severity;
  final String severityColor;
  final String disasterIcon;
  final String status;
  final String description;
  final List<DisasterImage>? images;

  Disaster({
    required this.id,
    required this.title,
    required this.disasterType,
    required this.city,
    required this.areaSector,
    required this.severity,
    required this.severityColor,
    required this.disasterIcon,
    required this.status,
    required this.description,
    this.images,
  });

  Color getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  factory Disaster.fromJson(Map<String, dynamic> json) {
    return Disaster(
      id: json['id'],
      title: json['title'] ?? '',
      disasterType: json['disaster_type'] ?? '',
      city: json['city'] ?? '',
      areaSector: json['area_sector'] ?? '',
      severity: json['severity'] ?? '',
      severityColor: json['severity_color'] ?? '',
      disasterIcon: json['disaster_icon'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null 
          ? (json['images'] as List).map((i) => DisasterImage.fromJson(i)).toList()
          : [],
    );
  }
}
