import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/disaster.dart';
import '../models/blood_request.dart';
import '../models/citizen_profile.dart';
import '../models/service_provider_profile.dart';
import '../models/disaster_alert.dart';
import '../models/disaster_response.dart';
import '../models/disaster_update.dart';

class ApiService {
  // Production URL
  static const String baseUrl = 'https://eras-1.onrender.com'; 

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/api/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('user_type', data['user']['user_type']);
      return true;
    }
    return false;
  }

  Future<bool> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts/api/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      // Registration successful and token returned
      final responseData = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', responseData['token']);
      await prefs.setString('user_type', responseData['user']['user_type']);
      return true;
    }
    
    print('Registration failed: ${response.body}');
    return false;
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/api/dashboard/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/api/profile/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/accounts/api/profile/update/'),
        headers: headers,
        body: jsonEncode(data),
      );

      print('Profile Update Response Status: ${response.statusCode}');
      print('Profile Update Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Profile Update Exception: $e');
      return false;
    }
  }

  Future<bool> reportDisaster(Map<String, dynamic> data, List<XFile> images) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl/disasters/api/disasters/');
    
    final request = http.MultipartRequest('POST', uri);
    
    request.headers.addAll({
      if (token != null) 'Authorization': 'Token $token',
    });

    data.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    for (XFile image in images) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'uploaded_images', 
          await image.readAsBytes(),
          filename: image.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('uploaded_images', image.path));
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        return true;
      }
      print('Failed to report disaster: ${response.body}');
      return false;
    } catch (e) {
      print('Error reporting disaster: $e');
      return false;
    }
  }

  Future<List<DisasterResponse>> getDisasterResponses(int disasterId) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/disasters/api/responses/?disaster=$disasterId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DisasterResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load responses');
    }
  }

  Future<List<DisasterUpdate>> getDisasterUpdates(int disasterId) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/disasters/api/updates/?disaster=$disasterId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DisasterUpdate.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load updates');
    }
  }

  Future<bool> addDisasterResponse(int disasterId, String status, String notes) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/disasters/api/responses/'),
      headers: headers,
      body: jsonEncode({
        'disaster': disasterId,
        'response_status': status,
        'response_notes': notes,
      }),
    );

    return response.statusCode == 201;
  }

  Future<List<BloodRequest>> getBloodRequests() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/api/blood-requests/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => BloodRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blood requests');
    }
  }

  Future<bool> createBloodRequest(Map<String, dynamic> data) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/accounts/api/blood-requests/'),
      headers: headers,
      body: jsonEncode(data),
    );

    return response.statusCode == 201;
  }

  Future<List<CitizenProfile>> searchDonors(String? bloodGroup, String? city) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    String url = '$baseUrl/accounts/api/donors/search/?';
    if (bloodGroup != null && bloodGroup.isNotEmpty) url += 'blood_group=${Uri.encodeComponent(bloodGroup)}&';
    if (city != null && city.isNotEmpty) url += 'city=${Uri.encodeComponent(city)}';

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CitizenProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search donors');
    }
  }

  Future<List<ServiceProviderProfile>> getServiceProviders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/accounts/api/providers/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceProviderProfile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load service providers');
    }
  }

  Future<bool> submitRating(int providerId, int rating, String review) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/accounts/api/providers/$providerId/rate/'),
      headers: headers,
      body: jsonEncode({'rating': rating, 'review': review}),
    );

    return response.statusCode == 200;
  }

  Future<List<DisasterAlert>> getAlerts() async {
    final token = await getToken();
    print('DEBUG: Token exists: ${token != null}');
    if (token != null) {
      print('DEBUG: Token starts with: ${token.substring(0, 5)}...');
    }
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/disasters/api/alerts/'),
      headers: headers,
    );

    print('Alerts API Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      try {
        final dynamic body = jsonDecode(response.body);
        if (body is List) {
          return body.map((json) => DisasterAlert.fromJson(json)).toList();
        } else if (body is Map && body.containsKey('results')) {
          return (body['results'] as List).map((json) => DisasterAlert.fromJson(json)).toList();
        }
        return [];
      } catch (e, stack) {
        print('Parsing Error: $e');
        print('Stack trace: $stack');
        print('Response body was: ${response.body}');
        throw Exception('Data parsing error');
      }
    } else {
      print('Alerts API Error Body: ${response.body}');
      throw Exception('Failed to load alerts');
    }
  }

  Future<bool> markAlertRead(int alertId) async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    final response = await http.post(
      Uri.parse('$baseUrl/disasters/api/alerts/$alertId/mark_read/'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      print('Mark Read API Error: ${response.statusCode} - ${response.body}');
    }

    return response.statusCode == 200;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_type');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

  Future<List<Disaster>> getDisasters() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/disasters/api/disasters/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Disaster.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load disasters');
    }
  }
}
