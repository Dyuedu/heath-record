import 'package:frontend/data/dio/dio_client.dart';
import 'package:frontend/data/models/notification_model.dart';
import 'package:dio/dio.dart';

class NotificationRepository {
  final DioClient _dioClient;

  NotificationRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dioClient.dio.put('/api/v1/notifications/$id/read');
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }
}
