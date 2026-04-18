import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateBloodRequestScreen extends StatefulWidget {
  @override
  _CreateBloodRequestScreenState createState() => _CreateBloodRequestScreenState();
}

class _CreateBloodRequestScreenState extends State<CreateBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  bool _isLoading = false;

  final _requesterNameController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _bagsNeededController = TextEditingController(text: '1');
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedBloodType = 'A+';
  String _selectedUrgency = 'normal';
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'requester_name': _requesterNameController.text,
      'patient_name': _patientNameController.text,
      'blood_type_needed': _selectedBloodType,
      'bags_needed': int.parse(_bagsNeededController.text),
      'location': _locationController.text,
      'contact_phone': _phoneController.text,
      'urgency': _selectedUrgency,
      'needed_by_date': "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
      'additional_notes': _notesController.text,
      'requester_city': _cityController.text,
      'status': 'open',
    };

    final success = await _apiService.createBloodRequest(data);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Blood request posted successfully!')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post request')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Blood', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Patient Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
              Divider(),
              TextFormField(
                controller: _patientNameController,
                decoration: InputDecoration(labelText: 'Patient Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      decoration: InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
                      items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                      onChanged: (v) => setState(() => _selectedBloodType = v!),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _bagsNeededController,
                      decoration: InputDecoration(labelText: 'Bags Needed', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text("Needed By: \${_selectedDate.year}-\${_selectedDate.month}-\${_selectedDate.day}"),
                trailing: Icon(Icons.calendar_today, color: Colors.red[700]),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              ),
              SizedBox(height: 24),
              
              Text('Contact & Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
              Divider(),
              TextFormField(
                controller: _requesterNameController,
                decoration: InputDecoration(labelText: 'Requester Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Contact Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Hospital / Location Details', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 24),
              
              Text('Additional Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700])),
              Divider(),
              DropdownButtonFormField<String>(
                value: _selectedUrgency,
                decoration: InputDecoration(labelText: 'Urgency', border: OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (v) => setState(() => _selectedUrgency = v!),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('POST REQUEST', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
