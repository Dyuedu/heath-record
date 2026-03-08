import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF246BFF)), onPressed: () => Navigator.pop(context)),
        title: const Text('Profile', style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
        centerTitle: true, elevation: 0, backgroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF246BFF)), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                const CircleAvatar(radius: 60, backgroundImage: NetworkImage('https://via.placeholder.com/150')),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFF246BFF), shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            _buildTextField('Full Name', 'John Doe'),
            _buildTextField('Phone Number', '+123 567 89000'),
            _buildTextField('Email', 'johndoe@example.com'),
            _buildTextField('Date Of Birth', 'DD / MM / YYYY'),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF246BFF), padding: const EdgeInsets.symmetric(vertical: 16), shape: StadiumBorder()),
                child: const Text('Update Profile', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFDDE3FF).withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}