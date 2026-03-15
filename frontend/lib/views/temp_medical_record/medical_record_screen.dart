import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/viewmodels/medical_record_viewmodel.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({super.key}); // No params!

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  @override
  void initState() {
    super.initState();
    // The UI just says "Go", it doesn't care about the ID details
    Future.microtask(() => context.read<MedicalRecordViewModel>().initFetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Records")),
      body: Consumer<MedicalRecordViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());

          if (vm.errorMessage != null) return Center(child: Text(vm.errorMessage!));

          return ListView.builder(
            itemCount: vm.records.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(vm.records[i].title),
              subtitle: Text(vm.records[i].hospitalName ?? ""),
            ),
          );
        },
      ),
    );
  }
}