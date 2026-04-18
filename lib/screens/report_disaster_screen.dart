import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'dart:io' show File;

class ReportDisasterScreen extends StatefulWidget {
  @override
  _ReportDisasterScreenState createState() => _ReportDisasterScreenState();
}

class _ReportDisasterScreenState extends State<ReportDisasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  bool _isLoading = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarksController = TextEditingController();
  final _contactController = TextEditingController();
  DateTime _incidentDateTime = DateTime.now();
  
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = 'natural';
  String _selectedSeverity = 'medium';
  String _selectedType = 'earthquake';

  final Map<String, List<Map<String, String>>> _disasterTypes = {
    'natural': [
      {'value': 'earthquake', 'label': 'Earthquake'},
      {'value': 'flood', 'label': 'Flood'},
      {'value': 'cyclone_storm', 'label': 'Cyclone/Storm'},
      {'value': 'wildfire', 'label': 'Fire (Wildfire)'},
      {'value': 'landslide', 'label': 'Landslide'},
      {'value': 'natural_other', 'label': 'Natural - Others'},
    ],
    'manmade': [
      {'value': 'building_fire', 'label': 'Building Fire'},
      {'value': 'industrial_accident', 'label': 'Industrial Accident'},
      {'value': 'transportation_accident', 'label': 'Transportation Accident'},
      {'value': 'gas_leak', 'label': 'Gas Leak'},
      {'value': 'structural_collapse', 'label': 'Structural Collapse'},
      {'value': 'manmade_other', 'label': 'Man-Made - Others'},
    ],
  };

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text.isEmpty ? 'Emergency Alert' : _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'disaster_type': _selectedType,
      'severity': _selectedSeverity,
      'city': _cityController.text,
      'area_sector': _areaController.text,
      'specific_address': _addressController.text,
      'landmarks': _landmarksController.text,
      'emergency_contact': _contactController.text,
      'incident_datetime': _incidentDateTime.toIso8601String(),
    };

    final success = await _apiService.reportDisaster(data, _selectedImages);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Emergency reported successfully!')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to report emergency')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report an Emergency', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 40),
                    SizedBox(width: 16),
                    Expanded(child: Text('Only report genuine emergencies. False reports may lead to account suspension.', style: TextStyle(color: Colors.red[900]))),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              Text('Emergency Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: 'natural', child: Text('Natural Disaster')),
                  DropdownMenuItem(value: 'manmade', child: Text('Man-Made Disaster')),
                ],
                onChanged: (v) {
                  setState(() {
                    _selectedCategory = v!;
                    _selectedType = _disasterTypes[v]!.first['value']!;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(labelText: 'Specific Type', border: OutlineInputBorder()),
                items: _disasterTypes[_selectedCategory]!.map((type) => 
                  DropdownMenuItem(value: type['value'], child: Text(type['label']!))
                ).toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSeverity,
                decoration: InputDecoration(labelText: 'Severity', border: OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: 'critical', child: Text('Critical (Life Threatening)')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                ],
                onChanged: (v) => setState(() => _selectedSeverity = v!),
              ),
              
              SizedBox(height: 24),
              Text('Location Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _areaController,
                      decoration: InputDecoration(labelText: 'Area/Sector', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
               TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Specific Address', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _landmarksController,
                decoration: InputDecoration(labelText: 'Nearby Landmarks', border: OutlineInputBorder()),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Emergency Contact Person Phone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24),
              Text('Date & Time of Incident', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context, 
                    initialDate: _incidentDateTime, 
                    firstDate: DateTime.now().subtract(Duration(days: 7)), 
                    lastDate: DateTime.now()
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context, 
                      initialTime: TimeOfDay.fromDateTime(_incidentDateTime)
                    );
                    if (time != null) {
                      setState(() {
                        _incidentDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                      });
                    }
                  }
                },
                icon: Icon(Icons.calendar_today),
                label: Text('${_incidentDateTime.day}/${_incidentDateTime.month}/${_incidentDateTime.year}  ${_incidentDateTime.hour}:${_incidentDateTime.minute}'),
              ),
              
              SizedBox(height: 24),
              Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _selectedImages.isEmpty 
                ? Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('No images selected')),
                  )
                : Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              width: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: kIsWeb 
                                    ? NetworkImage(_selectedImages[index].path)
                                    : FileImage(File(_selectedImages[index].path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImages.removeAt(index)),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                        if (image != null) setState(() => _selectedImages.add(image));
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text('Camera'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final List<XFile>? images = await _picker.pickMultiImage();
                        if (images != null) setState(() => _selectedImages.addAll(images));
                      },
                      icon: Icon(Icons.photo_library),
                      label: Text('Gallery'),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the situation briefly...',
                  border: OutlineInputBorder()
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
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
                    : Text('SUBMIT REPORT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
