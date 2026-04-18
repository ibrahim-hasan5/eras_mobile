import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/language_manager.dart';
import '../widgets/notification_action.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _apiService.getProfile();
  }

  void _logout() async {
    await _apiService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          NotificationAction(),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Colors.red[700]));
          if (snapshot.hasError) return Center(child: Text('Error loading profile'));
          
          final data = snapshot.data!;
          if (data['error'] != null) return Center(child: Text(data['error']));

          final user = data['user'] ?? {};
          
          return ListView(
            padding: EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.red[100],
                  child: Icon(Icons.person, size: 60, color: Colors.red[700]),
                ),
              ),
              SizedBox(height: 16),
              Center(child: Text(user['username'] ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
              Center(child: Text(user['email'] ?? '', style: TextStyle(fontSize: 16, color: Colors.grey[600]))),
              SizedBox(height: 32),
              
              Text('Account Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.phone, color: Colors.grey[700]),
                title: Text('Phone'),
                subtitle: Text(user['phone_number'] == null || user['phone_number'] == '' ? 'Not provided' : user['phone_number']),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.badge, color: Colors.grey[700]),
                title: Text('User Type'),
                subtitle: Text((user['user_type'] ?? '').toUpperCase()),
              ),

              SizedBox(height: 24),
              Text(LanguageManager().translate('language'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.language, color: Colors.grey[700]),
                title: Text(LanguageManager().currentLocale == 'en' ? 'Switch to Bengali' : 'Switch to English'),
                trailing: Text(LanguageManager().currentLocale == 'en' ? 'EN' : 'BN', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  LanguageManager().changeLanguage(LanguageManager().currentLocale == 'en' ? 'bn' : 'en');
                },
              ),
              
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        currentProfile: snapshot.data!,
                        userType: user['user_type'] ?? 'citizen',
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _profileFuture = _apiService.getProfile();
                    });
                  }
                },
                icon: Icon(Icons.edit),
                label: Text(LanguageManager().translate('edit_profile')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              
              SizedBox(height: 40),
              Text('App Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline),
                title: Text('About ERAS'),
                subtitle: Text('Emergency Reporting & Alert System'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'ERAS Mobile',
                    applicationVersion: '1.0.0',
                    applicationIcon: CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.emergency, color: Colors.white)),
                    children: [
                      Text('ERAS is a comprehensive platform for disaster management and blood network services in Bangladesh.'),
                    ],
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.code),
                title: Text('App Version'),
                subtitle: Text('1.0.0 (Production Build)'),
              ),
            ],
          );
        },
      ),
    );
  }
}
