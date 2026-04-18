import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  String _currentLocale = 'en';
  String get currentLocale => _currentLocale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLocale = prefs.getString('language_code') ?? 'en';
    notifyListeners();
  }

  Future<void> changeLanguage(String localeCode) async {
    _currentLocale = localeCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', localeCode);
    notifyListeners();
  }

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'ERAS Mobile',
      'dashboard': 'Dashboard',
      'explore': 'Explore',
      'blood': 'Blood',
      'alerts': 'Alerts',
      'profile': 'Profile',
      'report_emergency': 'Report Emergency',
      'request_blood': 'Request Blood',
      'search_donors': 'Search Donors',
      'active_emergencies': 'Active Emergencies',
      'nearby_services': 'Nearby Services',
      'language': 'Language',
      'about': 'About ERAS',
      'logout': 'Logout',
      'settings': 'Settings',
      'notifications': 'Notifications',
      'my_profile': 'My Profile',
      'edit_profile': 'Edit Profile',
    },
    'bn': {
      'app_title': 'ইরাস মোবাইল',
      'dashboard': 'ড্যাশবোর্ড',
      'explore': 'এক্সপ্লোর',
      'blood': 'রক্ত',
      'alerts': 'অ্যালার্ট',
      'profile': 'প্রোফাইল',
      'report_emergency': 'জরুরি রিপোর্ট',
      'request_blood': 'রক্তের আবেদন',
      'search_donors': 'ডোনার খুঁজুন',
      'active_emergencies': 'সক্রিয় জরুরি অবস্থা',
      'nearby_services': 'নিকটস্থ সেবা',
      'language': 'ভাষা পরিবর্তন',
      'about': 'ইরাস সম্পর্কে',
      'logout': 'লগআউট',
      'settings': 'সেটিংস',
      'notifications': 'নোটিফিকেশন',
      'my_profile': 'আমার প্রোফাইল',
      'edit_profile': 'প্রোফাইল এডিট',
    },
  };

  String translate(String key) {
    return _translations[_currentLocale]?[key] ?? _translations['en']?[key] ?? key;
  }
}
