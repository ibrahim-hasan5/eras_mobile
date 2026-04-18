import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'citizen_dashboard_screen.dart';
import 'provider_dashboard_screen.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';
import 'blood_network_screen.dart';
import 'alerts_screen.dart';
import '../services/language_manager.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  String _userType = 'citizen';

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  void _loadUserType() async {
    String? type = await _apiService.getUserType();
    if (type != null) {
      setState(() {
        _userType = type;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _userType == 'citizen' ? CitizenDashboardScreen() : ProviderDashboardScreen(),
      ExploreScreen(),
      BloodNetworkScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red[700],
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: LanguageManager().translate('dashboard')),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: LanguageManager().translate('explore')),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: LanguageManager().translate('blood')),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: LanguageManager().translate('profile')),
        ],
      ),
    );
  }
}
