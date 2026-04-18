import 'package:flutter/material.dart';
import '../models/service_provider_profile.dart';
import '../services/api_service.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ServiceProviderProfile provider;
  ProviderDetailScreen({required this.provider});

  @override
  _ProviderDetailScreenState createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final ApiService _apiService = ApiService();
  int _userRating = 5;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  void _submitRating() async {
    setState(() => _isSubmitting = true);
    final success = await _apiService.submitRating(widget.provider.id, _userRating, _reviewController.text);
    setState(() => _isSubmitting = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thank you for your feedback!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit rating')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final capacity = (p.maximumCapacity > 0) ? (p.currentCapacity / p.maximumCapacity) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.organizationName),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue[50],
                child: Icon(Icons.local_hospital, size: 40, color: Colors.blue[700]),
              ),
            ),
            SizedBox(height: 20),
            Center(child: Text(p.organizationName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            Center(child: Text(p.serviceType.toUpperCase(), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
            SizedBox(height: 30),
            
            Text('Status & Capacity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: capacity,
              backgroundColor: Colors.grey[200],
              color: capacity > 0.8 ? Colors.red : Colors.green,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            SizedBox(height: 5),
            Text('\${(capacity * 100).toStringAsFixed(0)}% Capacity Full'),
            SizedBox(height: 20),
            
            Text('Contact Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text(p.contactNumber),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text(p.email),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('City'),
              subtitle: Text(p.city),
            ),
            
            SizedBox(height: 30),
            Text('Rate this Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _userRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () => setState(() => _userRating = index + 1),
                );
              }),
            ),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(hintText: 'Share your experience...', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
                child: _isSubmitting ? CircularProgressIndicator(color: Colors.white) : Text('SUBMIT RATING'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
