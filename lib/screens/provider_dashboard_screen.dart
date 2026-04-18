import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/notification_action.dart';

class ProviderDashboardScreen extends StatefulWidget {
  @override
  _ProviderDashboardScreenState createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
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
        title: Text('Service Provider Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
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

          final capacity = (data['capacity_percentage'] ?? 0).toDouble();
          final rating = (data['avg_rating'] ?? 0).toDouble();
          final dStats = data['disaster_stats'] ?? {};

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
                      Expanded(child: Text('Please complete your profile from the website to be visible to citizens!')),
                    ],
                  ),
                ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Capacity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: capacity / 100,
                        backgroundColor: Colors.grey[200],
                        color: capacity > 80 ? Colors.red : Colors.green,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      SizedBox(height: 8),
                      Text('${capacity.toStringAsFixed(1)}% Full', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildStatCard('Average Rating', rating.toStringAsFixed(1), Icons.star),
              _buildStatCard('Disasters Responded', dStats['responded_to']?.toString() ?? '0', Icons.check_circle),
            ],
          );
        },
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
