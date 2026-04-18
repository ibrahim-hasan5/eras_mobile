import 'package:flutter/material.dart';
import '../models/disaster.dart';
import '../models/disaster_response.dart';
import '../models/disaster_update.dart';
import '../services/api_service.dart';
import 'add_response_screen.dart';

class DisasterDetailScreen extends StatefulWidget {
  final Disaster disaster;
  DisasterDetailScreen({required this.disaster});

  @override
  _DisasterDetailScreenState createState() => _DisasterDetailScreenState();
}

class _DisasterDetailScreenState extends State<DisasterDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<DisasterResponse>> _responsesFuture;
  late Future<List<DisasterUpdate>> _updatesFuture;

  @override
  void initState() {
    super.initState();
    _responsesFuture = _apiService.getDisasterResponses(widget.disaster.id);
    _updatesFuture = _apiService.getDisasterUpdates(widget.disaster.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.disaster.title),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.red[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.disaster.disasterType.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), 
                        backgroundColor: Colors.red[100]
                      ),
                      SizedBox(width: 8),
                      Chip(
                        label: Text(widget.disaster.severity.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)), 
                        backgroundColor: widget.disaster.severity == 'critical' ? Colors.red : Colors.orange
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('\${widget.disaster.areaSector}, \${widget.disaster.city}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(widget.disaster.description, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
                ],
              ),
            ),
            
            // Responses Section
            Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.emergency, color: Colors.red[700]),
                  SizedBox(width: 8),
                  Text('Responding Agencies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            FutureBuilder<List<DisasterResponse>>(
              future: _responsesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                final responses = snapshot.data ?? [];
                if (responses.isEmpty) return Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('No agencies responding yet.', style: TextStyle(color: Colors.grey)));
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: responses.length,
                  itemBuilder: (context, index) {
                    final r = responses[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue[50], child: Icon(Icons.local_hospital, color: Colors.blue[700])),
                        title: Text(r.organizationName, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Status: \${r.responseStatus.toUpperCase()}'),
                        trailing: Icon(Icons.info_outline, size: 16),
                      ),
                    );
                  },
                );
              },
            ),

            // Timeline Section
            Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.grey[700]),
                  SizedBox(width: 8),
                  Text('Response Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            FutureBuilder<List<DisasterUpdate>>(
              future: _updatesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                final updates = snapshot.data ?? [];
                if (updates.isEmpty) return Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('No updates yet.', style: TextStyle(color: Colors.grey)));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: updates.length,
                  itemBuilder: (context, index) {
                    final u = updates[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.red[300], shape: BoxShape.circle)),
                              if (index != updates.length - 1) Container(width: 2, height: 40, color: Colors.grey[300]),
                            ],
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.notes, style: TextStyle(fontWeight: FontWeight.w500)),
                                Text('\${u.updatedByName} • \${u.createdAt}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddResponseScreen(disasterId: widget.disaster.id)),
          );
          if (result == true) {
            setState(() {
              _responsesFuture = _apiService.getDisasterResponses(widget.disaster.id);
              _updatesFuture = _apiService.getDisasterUpdates(widget.disaster.id);
            });
          }
        },
        backgroundColor: Colors.blue[700],
        icon: Icon(Icons.add_task, color: Colors.white),
        label: Text('Respond to Emergency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
