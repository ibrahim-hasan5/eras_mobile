import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/blood_request.dart';
import '../models/citizen_profile.dart';
import 'create_blood_request_screen.dart';
import '../widgets/notification_action.dart';

class BloodNetworkScreen extends StatefulWidget {
  @override
  _BloodNetworkScreenState createState() => _BloodNetworkScreenState();
}

class _BloodNetworkScreenState extends State<BloodNetworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  late Future<List<BloodRequest>> _requestsFuture;
  late Future<List<CitizenProfile>> _donorsFuture;

  String? _selectedBloodGroup;
  final _cityController = TextEditingController();

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestsFuture = _apiService.getBloodRequests();
    _donorsFuture = _apiService.searchDonors(null, null);
  }

  void _refreshRequests() {
    setState(() {
      _requestsFuture = _apiService.getBloodRequests();
    });
  }

  void _searchDonors() {
    setState(() {
      _donorsFuture = _apiService.searchDonors(_selectedBloodGroup, _cityController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Network', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [NotificationAction()],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.red[200],
          tabs: [
            Tab(icon: Icon(Icons.list), text: 'Open Requests'),
            Tab(icon: Icon(Icons.search), text: 'Find Donors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildDonorsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateBloodRequestScreen()),
          );
          if (result == true) {
            _refreshRequests();
          }
        },
        backgroundColor: Colors.red[700],
        icon: Icon(Icons.water_drop, color: Colors.white),
        label: Text('Request Blood', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshRequests(),
      child: FutureBuilder<List<BloodRequest>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Colors.red[700]));
          if (snapshot.hasError) return Center(child: Text('Error loading requests'));

          final requests = snapshot.data ?? [];
          final openRequests = requests.where((r) => r.status == 'open').toList();

          if (openRequests.isEmpty) return Center(child: Text('No open blood requests.', style: TextStyle(fontSize: 16)));

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: openRequests.length,
            itemBuilder: (context, index) {
              final r = openRequests[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red[100],
                    radius: 30,
                    child: Text(r.bloodTypeNeeded, style: TextStyle(color: Colors.red[700], fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  title: Text('${r.patientName} (${r.bagsNeeded} bags)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey), SizedBox(width: 4), Expanded(child: Text(r.location))]),
                      SizedBox(height: 4),
                      Row(children: [Icon(Icons.phone, size: 14, color: Colors.grey), SizedBox(width: 4), Text(r.contactPhone)]),
                      SizedBox(height: 4),
                      Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey), SizedBox(width: 4), Text('Needed by: ${r.neededByDate}')]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDonorsTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedBloodGroup,
                      decoration: InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder(), isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text('Any')),
                        ..._bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                      ],
                      onChanged: (v) => setState(() => _selectedBloodGroup = v),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(labelText: 'City', border: OutlineInputBorder(), isDense: true),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _searchDonors,
                  icon: Icon(Icons.search),
                  label: Text('Search Donors'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<CitizenProfile>>(
            future: _donorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Colors.red[700]));
              if (snapshot.hasError) return Center(child: Text('Error loading donors'));

              final donors = snapshot.data ?? [];
              if (donors.isEmpty) return Center(child: Text('No donors found for this criteria.'));

              return ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: donors.length,
                itemBuilder: (context, index) {
                  final d = donors[index];
                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[50],
                        child: Text(d.bloodGroup, style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                      ),
                      title: Text(d.phoneNumber), // Accessing phone number as display
                      subtitle: Text(d.city),
                      trailing: IconButton(
                        icon: Icon(Icons.phone, color: Colors.green),
                        onPressed: () {
                          // Note: In real app would use url_launcher
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contact: ${d.phoneNumber}')));
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
