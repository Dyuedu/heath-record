import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/repositories/record_repository.dart';
import 'package:frontend/data/models/hospital_response.dart';
import 'package:frontend/data/models/relative_search_response.dart';

class DiagnosticFormModel {
  TextEditingController categoryController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  TextEditingController dataController = TextEditingController();
  List<File> images = [];
}

class CreateMedicalRecordPage extends StatefulWidget {
  const CreateMedicalRecordPage({super.key});

  @override
  State<CreateMedicalRecordPage> createState() => _CreateMedicalRecordPageState();
}

class _CreateMedicalRecordPageState extends State<CreateMedicalRecordPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  ProfileSearchResponse? _selectedRelative;
  HospitalResponse? _selectedHospital;
  List<HospitalResponse> _hospitals = [];

  final List<DiagnosticFormModel> _diagnostics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHospitals();
    });
  }

  Future<void> _loadHospitals() async {
    final repository = context.read<RecordRepository>();
    final h = await repository.getHospitals();
    if (mounted) {
      setState(() {
        _hospitals = h;
      });
    }
  }

  void _addDiagnostic() {
    setState(() {
      _diagnostics.add(DiagnosticFormModel());
    });
  }

  void _removeDiagnostic(int index) {
    setState(() {
      _diagnostics.removeAt(index);
    });
  }

  Future<void> _pickImages(int index) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _diagnostics[index].images.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRelative == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a patient.')));
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final repository = context.read<RecordRepository>();
      
      List<Map<String, dynamic>> diagPayloads = [];
      for (var diag in _diagnostics) {
        List<String> imageUrls = [];
        for (var file in diag.images) {
           final url = await repository.uploadDiagnosticImage(file);
           if (url != null) imageUrls.add(url);
        }
        diagPayloads.add({
          "category": diag.categoryController.text,
          "tag": diag.tagController.text,
          "data": diag.dataController.text,
          "imageUrls": imageUrls,
        });
      }
      
      final payload = {
        "patientProfileId": _selectedRelative!.id,
        "title": _titleController.text,
        "note": _noteController.text,
        "hospitalId": _selectedHospital?.id,
        "diagnostics": diagPayloads
      };

      final success = await repository.createFullMedicalRecord(payload);
      if (success) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record created successfully!')));
           Navigator.pop(context);
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create record.')));
        }
      }
    } catch (e) {
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Medical Record', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF246BFF),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF246BFF)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('General Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF246BFF))),
                   const SizedBox(height: 16),
                   _buildTextField(_titleController, 'Record Title', Icons.title, required: true),
                   const SizedBox(height: 12),
                   _buildRelativeSearch(),
                   const SizedBox(height: 12),
                   _buildHospitalSearch(),
                   const SizedBox(height: 12),
                   _buildTextField(_noteController, 'General Notes', Icons.notes, maxLines: 3),
                   const SizedBox(height: 24),
                   const Divider(),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Diagnostics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF246BFF))),
                       IconButton(
                         icon: const Icon(Icons.add_circle, color: Color(0xFF246BFF), size: 30),
                         onPressed: _addDiagnostic,
                       )
                     ],
                   ),
                   const SizedBox(height: 10),
                   ..._diagnostics.asMap().entries.map((entry) {
                     int idx = entry.key;
                     DiagnosticFormModel diag = entry.value;
                     return Card(
                       margin: const EdgeInsets.only(bottom: 16),
                       elevation: 3,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       child: Padding(
                         padding: const EdgeInsets.all(16),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 Text('Diagnostic #${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                 IconButton(
                                   icon: const Icon(Icons.delete, color: Colors.red),
                                   onPressed: () => _removeDiagnostic(idx),
                                 )
                               ],
                             ),
                             _buildTextField(diag.categoryController, 'Category', Icons.category, required: true),
                             const SizedBox(height: 8),
                             _buildTextField(diag.tagController, 'Tag', Icons.label),
                             const SizedBox(height: 8),
                             _buildTextField(diag.dataController, 'Diagnosis Data / Results', Icons.analytics, maxLines: 2),
                             const SizedBox(height: 16),
                             Row(
                               children: [
                                 ElevatedButton.icon(
                                   onPressed: () => _pickImages(idx), 
                                   icon: const Icon(Icons.image), 
                                   label: const Text('Add Images'),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: const Color(0xFFDDE3FF),
                                     foregroundColor: const Color(0xFF246BFF),
                                     elevation: 0
                                   ),
                                 ),
                               ],
                             ),
                             if (diag.images.isNotEmpty) ...[
                               const SizedBox(height: 10),
                               Wrap(
                                 spacing: 8,
                                 runSpacing: 8,
                                 children: diag.images.map((file) => ClipRRect(
                                   borderRadius: BorderRadius.circular(8),
                                   child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
                                 )).toList(),
                               )
                             ]
                           ],
                         ),
                       ),
                     );
                   }),
                   const SizedBox(height: 30),
                   SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF246BFF),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                       ),
                       onPressed: _submitForm,
                       child: const Text('Submit Medical Record', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                     ),
                   ),
                   const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: '$label${required ? ' *' : ''}',
        prefixIcon: Icon(icon, color: const Color(0xFF246BFF)),
        filled: true,
        fillColor: const Color(0xFFDDE3FF).withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: required ? ((v) => (v == null || v.isEmpty) ? 'This field is required' : null) : null,
    );
  }

  Widget _buildRelativeSearch() {
    return Autocomplete<ProfileSearchResponse>(
      displayStringForOption: (option) => option.fullName,
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<ProfileSearchResponse>.empty();
        }
        final repository = context.read<RecordRepository>();
        return await repository.searchPatientProfiles(textEditingValue.text);
      },
      onSelected: (ProfileSearchResponse selection) {
        setState(() {
          _selectedRelative = selection;
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              height: 250.0,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: option.avatarUrl.isNotEmpty ? NetworkImage(option.avatarUrl) : null,
                        child: option.avatarUrl.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(option.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('DOB: ${option.dateOfBirth} - ${option.relationship}'),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Patient / Relative (Search by Name/Phone) *',
            prefixIcon: const Icon(Icons.person, color: Color(0xFF246BFF)),
            suffixIcon: _selectedRelative != null || textEditingController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    textEditingController.clear();
                    setState(() => _selectedRelative = null);
                  },
                )
              : null,
            filled: true,
            fillColor: const Color(0xFFDDE3FF).withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
          validator: (v) => _selectedRelative == null ? 'Please select a patient' : null,
        );
      },
    );
  }

  Widget _buildHospitalSearch() {
    return Autocomplete<HospitalResponse>(
      displayStringForOption: (option) => option.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _hospitals;
        }
        return _hospitals.where((HospitalResponse option) {
          return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (HospitalResponse selection) {
        setState(() {
          _selectedHospital = selection;
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              height: 200.0,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Hospital (Search by Name)',
            prefixIcon: const Icon(Icons.local_hospital, color: Color(0xFF246BFF)),
            suffixIcon: _selectedHospital != null || textEditingController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    textEditingController.clear();
                    setState(() => _selectedHospital = null);
                  },
                )
              : null,
            filled: true,
            fillColor: const Color(0xFFDDE3FF).withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        );
      },
    );
  }
}
