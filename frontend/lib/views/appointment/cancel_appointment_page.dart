import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_nav.dart';

class CancelPage extends StatefulWidget {
  const CancelPage({super.key});

  @override
  State<CancelPage> createState() => _CancelPageState();
}

class _CancelPageState extends State<CancelPage> {
  String? selectedReason = 'Weather Conditions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)), onPressed: () => Navigator.pop(context)),
        title: const Text('Cancel Appointment', style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
        centerTitle: true, elevation: 0, backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor...', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),
            _radioOption('Rescheduling'),
            _radioOption('Weather Conditions'),
            _radioOption('Unexpected Work'),
            _radioOption('Others'),
            const SizedBox(height: 20),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter Your Reason Here...',
                fillColor: const Color(0xFFDDE3FF).withOpacity(0.5),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF246BFF), padding: const EdgeInsets.symmetric(vertical: 15), shape: StadiumBorder()),
                child: const Text('Cancel Appointment', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _radioOption(String title) {
    bool isSelected = selectedReason == title;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFDDE3FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: RadioListTile<String>(
        title: Text(title),
        value: title,
        groupValue: selectedReason,
        activeColor: const Color(0xFF246BFF),
        onChanged: (val) => setState(() => selectedReason = val),
      ),
    );
  }
}