import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'report_disaster_screen.dart';
import '../widgets/notification_action.dart';
import '../services/language_manager.dart';

class CitizenDashboardScreen extends StatefulWidget {
  @override
  _CitizenDashboardScreenState createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _apiService.getDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Citizen Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [NotificationAction()],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red[700]));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading dashboard'));
          }

          final data = snapshot.data!;
          if (data['error'] != null) {
            return Center(child: Text("Error: ${data['error']}"));
          }

          final dStats = data['disaster_stats'] ?? {};
          final bStats = data['blood_stats'] ?? {};

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              if (data['profile_complete'] == false)
                Container(
                  color: Colors.orange[100],
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[800]),
                      SizedBox(width: 8),
                      Expanded(child: Text('Please complete your profile to use all features!')),
                    ],
                  ),
                ),
              _buildStatCard('Reported Disasters', dStats['total']?.toString() ?? '0', Icons.warning),
              _buildStatCard('Pending Disasters', dStats['pending']?.toString() ?? '0', Icons.hourglass_empty),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('ERAS - Emergency Reporting & Alert System', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
                    SizedBox(height: 8),
                    Text(LanguageManager().translate('app_title'), style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportDisasterScreen()),
          );
          if (result == true) {
            setState(() {
              _dashboardFuture = _apiService.getDashboard();
            });
          }
        },
        backgroundColor: Colors.red[700],
        icon: Icon(Icons.add_alert, color: Colors.white),
        label: Text(LanguageManager().translate('report_emergency'), style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(backgroundColor: Colors.red[100], child: Icon(icon, color: Colors.red[700])),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red[700])),
      ),
    );
  }
}
