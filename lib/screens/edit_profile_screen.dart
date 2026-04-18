import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/language_manager.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentProfile;
  final String userType;

  EditProfileScreen({required this.currentProfile, required this.userType});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  late TextEditingController _fullNameController;
  late TextEditingController _cityController;
  late TextEditingController _areaController;
  late TextEditingController _phoneController;
  
  // For Citizen
  String? _bloodGroup;
  late TextEditingController _dobController;
  late TextEditingController _houseController;
  late TextEditingController _postalController;
  late TextEditingController _landmarksController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  
  // For Service Provider
  late TextEditingController _orgNameController;
  late TextEditingController _emailController;
  late TextEditingController _regNoController;
  late TextEditingController _addressController;
  late TextEditingController _primaryContactController;
  late TextEditingController _hotlineController;
  String? _serviceType;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _serviceTypes = ['Hospital', 'Ambulance', 'Fire Service', 'Police', 'Volunteer'];

  @override
  void initState() {
    super.initState();
    final profile = widget.currentProfile['profile'] ?? {};
    final user = widget.currentProfile['user'] ?? {};

    _fullNameController = TextEditingController(text: profile['full_name'] ?? user['username']);
    _cityController = TextEditingController(text: profile['city'] ?? '');
    _areaController = TextEditingController(text: profile['area_sector'] ?? '');
    _phoneController = TextEditingController(text: profile['phone_number'] ?? '');
    
    if (widget.userType == 'citizen') {
      _bloodGroup = profile['blood_group'];
      _dobController = TextEditingController(text: profile['date_of_birth'] ?? '');
      _houseController = TextEditingController(text: profile['house_road_no'] ?? '');
      _postalController = TextEditingController(text: profile['postal_code'] ?? '');
      _landmarksController = TextEditingController(text: profile['landmarks'] ?? '');
      _emergencyNameController = TextEditingController(text: profile['emergency_contact_name'] ?? '');
      _emergencyPhoneController = TextEditingController(text: profile['emergency_contact_phone'] ?? '');
    } else {
      _orgNameController = TextEditingController(text: profile['organization_name'] ?? '');
      _emailController = TextEditingController(text: profile['email'] ?? '');
      _regNoController = TextEditingController(text: profile['registration_number'] ?? '');
      _addressController = TextEditingController(text: profile['street_address'] ?? '');
      _primaryContactController = TextEditingController(text: profile['primary_contact_person'] ?? '');
      _hotlineController = TextEditingController(text: profile['emergency_hotline'] ?? '');
      _serviceType = profile['service_type'];
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _phoneController.dispose();
    if (widget.userType == 'service_provider') _orgNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      'full_name': _fullNameController.text,
      'city': _cityController.text,
      'area_sector': _areaController.text,
      'phone_number': _phoneController.text,
    };

    if (widget.userType == 'citizen') {
      data.addAll({
        'blood_group': _bloodGroup,
        'date_of_birth': _dobController.text,
        'house_road_no': _houseController.text,
        'postal_code': _postalController.text,
        'landmarks': _landmarksController.text,
        'emergency_contact_name': _emergencyNameController.text,
        'emergency_contact_phone': _emergencyPhoneController.text,
      });
    } else {
      data.addAll({
        'organization_name': _orgNameController.text,
        'service_type': _serviceType,
        'email': _emailController.text,
        'registration_number': _regNoController.text,
        'street_address': _addressController.text,
        'primary_contact_person': _primaryContactController.text,
        'emergency_hotline': _hotlineController.text,
      });
    }

    try {
      final success = await _apiService.updateProfile(data);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageManager().translate('edit_profile')),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.red[700]))
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 16),
                  
                   if (widget.userType == 'citizen') ...[
                    TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)', prefixIcon: Icon(Icons.cake), border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _houseController,
                      decoration: InputDecoration(labelText: 'House / Road No', prefixIcon: Icon(Icons.home), border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                  ],

                  if (widget.userType == 'service_provider') ...[
                    TextFormField(
                      controller: _orgNameController,
                      decoration: InputDecoration(labelText: 'Organization Name', prefixIcon: Icon(Icons.business), border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _regNoController,
                      decoration: InputDecoration(labelText: 'Registration Number', prefixIcon: Icon(Icons.app_registration), border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _serviceTypes.map((t) => t.toLowerCase()).contains(_serviceType?.toLowerCase()) ? _serviceType : null,
                      decoration: InputDecoration(labelText: 'Service Type', prefixIcon: Icon(Icons.category), border: OutlineInputBorder()),
                      items: _serviceTypes.map((t) => DropdownMenuItem(value: t.toLowerCase(), child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _serviceType = v),
                    ),
                    SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city), border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _areaController,
                          decoration: InputDecoration(labelText: 'Area / Sector', prefixIcon: Icon(Icons.map), border: OutlineInputBorder()),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  if (widget.userType == 'citizen') ...[
                    TextFormField(
                      controller: _postalController,
                      decoration: InputDecoration(labelText: 'Postal Code', prefixIcon: Icon(Icons.pin_drop), border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _landmarksController,
                      decoration: InputDecoration(labelText: 'Landmarks', prefixIcon: Icon(Icons.landscape), border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 24),
                    Text('Emergency Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
                    Divider(),
                    TextFormField(
                      controller: _emergencyNameController,
                      decoration: InputDecoration(labelText: 'Contact Name', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emergencyPhoneController,
                      decoration: InputDecoration(labelText: 'Contact Phone', prefixIcon: Icon(Icons.phone_android), border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),
                  ],

                  if (widget.userType == 'service_provider') ...[
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Full Address', prefixIcon: Icon(Icons.home_work), border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _primaryContactController,
                      decoration: InputDecoration(labelText: 'Primary Contact Person', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _hotlineController,
                      decoration: InputDecoration(labelText: 'Emergency Hotline', prefixIcon: Icon(Icons.phone_in_talk), border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                    ),
                  ],

                  SizedBox(height: 16),
                  if (widget.userType == 'citizen')
                    DropdownButtonFormField<String>(
                      value: _bloodGroups.contains(_bloodGroup) ? _bloodGroup : null,
                      decoration: InputDecoration(
                        labelText: 'Blood Group',
                        prefixIcon: Icon(Icons.bloodtype),
                        border: OutlineInputBorder(),
                      ),
                      items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      onChanged: (v) => setState(() => _bloodGroup = v),
                    ),
                  
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
