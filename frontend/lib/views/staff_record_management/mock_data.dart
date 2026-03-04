import 'package:frontend/views/staff_record_management/models.dart';

List<MedicalRecord> mockRecords = [
  MedicalRecord(
    id: "1",
    patientName: "Phan Vũ Công Hưng",
    patientCode: "0123456",
    title: "Xét nghiệm máu",
    type: "Xét nghiệm",
    date: DateTime(2026, 1, 1),
    doctor: "BS. Nguyễn Văn A",
    description: "Kết quả xét nghiệm máu tổng quát.",
    tags: ["blood-test", "cholesterol"],
    imagePaths: ["assets/images/login_bg.png", "assets/images/login_bg.png"],
  ),
  MedicalRecord(
    id: "2",
    patientName: "Nguyễn Thị Mai",
    patientCode: "0456123",
    title: "Chụp X-Quang phổi",
    type: "Chẩn đoán",
    date: DateTime(2026, 1, 5),
    doctor: "BS. Trần Văn B",
    description: "Chẩn đoán viêm phổi nhẹ.",
    tags: ["imaging"],
    imagePaths: ["assets/images/login_bg.png"],
  ),
];