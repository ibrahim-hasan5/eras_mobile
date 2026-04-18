import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedRole = 'citizen';

  // Shared Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Citizen Controllers
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Service Provider Controllers
  final _orgNameController = TextEditingController();
  final _contactNumberController = TextEditingController();

  // Service Type options
  final List<String> _serviceTypes = [
    'hospital', 'ambulance', 'fire_station', 'police', 
    'blood_bank', 'volunteer_group', 'others'
  ];
  String _selectedServiceType = 'hospital';

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    Map<String, dynamic> data = {
      'user_type': _selectedRole,
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    if (_selectedRole == 'citizen') {
      data['username'] = _usernameController.text;
      data['phone_number'] = _phoneController.text;
    } else {
      data['organization_name'] = _orgNameController.text;
      data['service_type'] = _selectedServiceType;
      data['contact_number'] = _contactNumberController.text;
    }

    bool success = await _apiService.register(data);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Check inputs or try a different username/organization.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.person_add, size: 60, color: Colors.red[700]),
                SizedBox(height: 24),
                
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'I want to register as a',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge, color: Colors.red[700]),
                  ),
                  items: [
                    DropdownMenuItem(value: 'citizen', child: Text('Citizen')),
                    DropdownMenuItem(value: 'service_provider', child: Text('Service Provider')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                SizedBox(height: 16),
                
                // --- CITIZEN FIELDS ---
                if (_selectedRole == 'citizen') ...[
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],

                // --- SERVICE PROVIDER FIELDS ---
                if (_selectedRole == 'service_provider') ...[
                  TextFormField(
                    controller: _orgNameController,
                    decoration: InputDecoration(labelText: 'Organization Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.business)),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedServiceType,
                    decoration: InputDecoration(labelText: 'Service Type', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
                    items: _serviceTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                    onChanged: (v) => setState(() => _selectedServiceType = v!),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _contactNumberController,
                    decoration: InputDecoration(labelText: 'Contact Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],

                SizedBox(height: 16),
                
                // --- SHARED FIELDS ---
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter valid email' : null,
                ),
                SizedBox(height: 16),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                  validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                ),
                SizedBox(height: 24),
                
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(_errorMessage, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white) 
                    : Text('Register', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
