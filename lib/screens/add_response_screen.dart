import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddResponseScreen extends StatefulWidget {
  final int disasterId;
  AddResponseScreen({required this.disasterId});

  @override
  _AddResponseScreenState createState() => _AddResponseScreenState();
}

class _AddResponseScreenState extends State<AddResponseScreen> {
  final _apiService = ApiService();
  final _notesController = TextEditingController();
  String _selectedStatus = 'responding';
  bool _isLoading = false;

  void _submit() async {
    if (_notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add some notes about your response.')));
      return;
    }

    setState(() => _isLoading = true);
    final success = await _apiService.addDisasterResponse(
      widget.disasterId, 
      _selectedStatus, 
      _notesController.text
    );
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated successfully!')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update. Only Service Providers can respond.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Response Status'), 
        backgroundColor: Colors.blue[700], 
        foregroundColor: Colors.white
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Update your agency\'s current status for this incident.', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'New Status', 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings_suggest, color: Colors.blue[700]),
              ),
              items: [
                DropdownMenuItem(value: 'responding', child: Text('Responding')),
                DropdownMenuItem(value: 'on_scene', child: Text('On Scene')),
                DropdownMenuItem(value: 'completed', child: Text('Response Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (v) => setState(() => _selectedStatus = v!),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Response Notes', 
                hintText: 'e.g., ETA 10 mins, team dispatched...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 56), 
                backgroundColor: Colors.blue[700], 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white) 
                : Text('UPDATE STATUS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
