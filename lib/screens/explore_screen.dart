import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/disaster.dart';
import '../models/service_provider_profile.dart';
import 'report_disaster_screen.dart';
import 'provider_detail_screen.dart';
import 'disaster_detail_screen.dart';
import '../widgets/notification_action.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  
  late Future<List<Disaster>> _disastersFuture;
  late Future<List<ServiceProviderProfile>> _providersFuture;
  
  List<Disaster> _allDisasters = [];
  List<Disaster> _filteredDisasters = [];
  List<ServiceProviderProfile> _allProviders = [];
  List<ServiceProviderProfile> _filteredProviders = [];

  String _searchQuery = "";
  String _selectedDisasterCategory = "All";
  String _selectedProviderCategory = "All";

  final List<String> _disasterCategories = ['All', 'Fire', 'Flood', 'Earthquake', 'Accident', 'Medical', 'Other'];
  final List<String> _providerCategories = ['All', 'Hospital', 'Ambulance', 'Fire Service', 'Police', 'Volunteer'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadData();
  }

  void _loadData() {
    _disastersFuture = _apiService.getDisasters().then((data) {
      _allDisasters = data;
      _applyFilters();
      return data;
    });
    _providersFuture = _apiService.getServiceProviders().then((data) {
      _allProviders = data;
      _applyFilters();
      return data;
    });
  }

  void _applyFilters() {
    setState(() {
      // Filter Disasters
      _filteredDisasters = _allDisasters.where((d) {
        final matchesSearch = d.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                             d.city.toLowerCase().contains(_searchQuery.toLowerCase());
        
        bool matchesCategory = _selectedDisasterCategory == "All";
        if (!matchesCategory) {
          final type = d.disasterType.toLowerCase();
          final selected = _selectedDisasterCategory.toLowerCase();
          
          if (selected == 'fire') {
            matchesCategory = type.contains('fire');
          } else if (selected == 'accident') {
            matchesCategory = type.contains('accident') || type.contains('collapse');
          } else if (selected == 'medical') {
            matchesCategory = type.contains('medical') || type.contains('chemical');
          } else {
            matchesCategory = type == selected;
          }
        }
        return matchesSearch && matchesCategory;
      }).toList();

      // Filter Providers
      _filteredProviders = _allProviders.where((p) {
        final matchesSearch = p.organizationName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                             p.city.toLowerCase().contains(_searchQuery.toLowerCase());
        
        bool matchesCategory = _selectedProviderCategory == "All";
        if (!matchesCategory) {
          final type = p.serviceType.toLowerCase();
          final selected = _selectedProviderCategory.toLowerCase();
          
          if (selected == 'fire service') {
            matchesCategory = type.contains('fire');
          } else if (selected == 'police') {
            matchesCategory = type.contains('police');
          } else if (selected == 'ambulance') {
            matchesCategory = type.contains('ambulance');
          } else {
            matchesCategory = type.contains(selected);
          }
        }
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore ERAS', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [NotificationAction()],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.red[200],
          tabs: [
            Tab(text: 'Emergencies'),
            Tab(text: 'Services'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Search emergencies or services...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
            ),
          ),
          
          // Category Chips
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: (_tabController.index == 0 ? _disasterCategories : _providerCategories).map((cat) {
                final isSelected = (_tabController.index == 0 ? _selectedDisasterCategory : _selectedProviderCategory) == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (_tabController.index == 0) {
                          _selectedDisasterCategory = cat;
                        } else {
                          _selectedProviderCategory = cat;
                        }
                        _applyFilters();
                      });
                    },
                    selectedColor: Colors.red[100],
                    checkmarkColor: Colors.red[700],
                    labelStyle: TextStyle(color: isSelected ? Colors.red[700] : Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDisastersTab(),
                  _buildProvidersTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0 ? FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportDisasterScreen()),
          );
          if (result == true) {
            setState(() {
              _disastersFuture = _apiService.getDisasters();
            });
          }
        },
        backgroundColor: Colors.red[700],
        icon: Icon(Icons.warning, color: Colors.white),
        label: Text('Report Emergency', style: TextStyle(color: Colors.white)),
      ) : null,
    );
  }

   Widget _buildDisastersTab() {
    return FutureBuilder<List<Disaster>>(
      future: _disastersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _allDisasters.isEmpty) return Center(child: CircularProgressIndicator(color: Colors.red[700]));
        
        final disasters = _filteredDisasters;
        if (disasters.isEmpty) return Center(child: Text('No emergencies found matching criteria.'));

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: disasters.length,
          itemBuilder: (context, index) {
            final d = disasters[index];
            final imageUrl = (d.images != null && d.images!.isNotEmpty) 
                ? (d.images![0].image.startsWith('http') 
                    ? d.images![0].image 
                    : '${ApiService.baseUrl}${d.images![0].image.startsWith('/') ? '' : '/'}${d.images![0].image}')
                : null;

            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisasterDetailScreen(disaster: d)),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(d.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: d.getSeverityColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(d.severity.toUpperCase(), style: TextStyle(color: d.getSeverityColor(), fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text('${d.areaSector}, ${d.city}', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

   Widget _buildProvidersTab() {
    return FutureBuilder<List<ServiceProviderProfile>>(
      future: _providersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _allProviders.isEmpty) return Center(child: CircularProgressIndicator(color: Colors.red[700]));

        final providers = _filteredProviders;
        if (providers.isEmpty) return Center(child: Text('No service providers found.'));

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: providers.length,
          itemBuilder: (context, index) {
            final p = providers[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(
                    p.serviceType == 'Hospital' ? Icons.local_hospital : 
                    p.serviceType == 'Ambulance' ? Icons.emergency : Icons.business, 
                    color: Colors.blue[700]
                  ),
                ),
                title: Text(p.organizationName, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${p.serviceType} • ${p.city}'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProviderDetailScreen(provider: p)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
