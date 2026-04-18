import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/disaster_alert.dart';

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<DisasterAlert>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _alertsFuture = _apiService.getAlerts();
  }

  void _markAsRead(int id) async {
    await _apiService.markAlertRead(id);
    setState(() {
      _alertsFuture = _apiService.getAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _alertsFuture = _apiService.getAlerts();
          });
          await _alertsFuture;
        },
        child: FutureBuilder<List<DisasterAlert>>(
          future: _alertsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.red[700]));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading alerts'));
            }

            final alerts = snapshot.data ?? [];
            if (alerts.isEmpty) {
              return ListView( // ListView needed for RefreshIndicator to work on empty list
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No new alerts. Stay safe!', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              itemCount: alerts.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Container(
                  color: alert.isRead ? Colors.transparent : Colors.red.withOpacity(0.05),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: alert.severity == 'critical' ? Colors.red : Colors.orange,
                      child: Icon(Icons.warning, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      alert.title,
                      style: TextStyle(fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\${alert.type} • \${alert.location}'),
                        SizedBox(height: 4),
                        Text(alert.sentAt, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    isThreeLine: true,
                    onTap: () {
                      if (!alert.isRead) _markAsRead(alert.id);
                    },
                    trailing: alert.isRead 
                      ? null 
                      : Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
