import 'package:flutter/material.dart';
import 'package:frontend/data/models/profile_model.dart';



class ProfileViewModel extends ChangeNotifier {
  // Giả lập dữ liệu dựa trên ảnh mẫu
  final List<ProfileModel> _profiles = [
    ProfileModel(
      id: '1',
      fullName: 'Phan Vũ Công Hưng',
      medicalCode: '0123456',
      birthDate: '01/01/2000',
      phoneNumber: '0987654321',
      address: 'Hà Nội',
      gender: 'Nam',
    ),
    ProfileModel(
        id: '2',
        fullName: 'Trần Xuân Chiến',
        medicalCode: '0123465',
        birthDate: '15/05/1998',
        phoneNumber: '0123456789',
        gender: 'Nam',
        address: 'Đà Nẵng',
        medicalHistory: 'Chưa cập nhật',
        allergy: 'Chưa cập nhật'
    ),
  ];

  List<ProfileModel> get profiles => _profiles;
}