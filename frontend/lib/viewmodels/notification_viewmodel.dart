import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:frontend/data/models/notification_model.dart';
import 'package:frontend/data/repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository repository;
  StompClient? _stompClient;
  bool _isConnected = false;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  NotificationViewModel({required this.repository});

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isConnected => _isConnected;

  Future<void> fetchNotifications() async {
    try {
      _notifications = await repository.getNotifications();
      _calculateUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    }
  }

  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      try {
        await repository.markAsRead(id);
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _calculateUnreadCount();
        notifyListeners();
      } catch (e) {
        debugPrint('Error marking as read: $e');
      }
    }
  }

  void connect(String userId) {
    if (_stompClient != null && _isConnected) return;
    fetchNotifications();

    final String wsUrl = 'ws://192.168.224.149:8081/ws-notifications';

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (StompFrame frame) {
          _isConnected = true;
          notifyListeners();
          
          _stompClient?.subscribe(
            destination: '/topic/notifications/$userId',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                try {
                  final Map<String, dynamic> result = json.decode(frame.body!);
                  final NotificationModel newNotif = NotificationModel.fromJson(result);
                  _notifications.insert(0, newNotif);
                  _calculateUnreadCount();
                  notifyListeners();
                  _showNotification(result);
                } catch (e) {
                  debugPrint('Error parsing notification json: $e');
                }
              }
            },
          );
        },
        onWebSocketError: (dynamic error) {
          debugPrint('WebSocket Error: $error');
        },
        onStompError: (StompFrame frame) {
          debugPrint('STOMP Error: ${frame.body}');
        },
        onDisconnect: (StompFrame frame) {
          _isConnected = false;
          notifyListeners();
        },
      ),
    );

    _stompClient?.activate();
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnected = false;
    notifyListeners();
  }

  void clearSessionData() {
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnected = false;
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }

  void _showNotification(Map<String, dynamic> notification) {
    final title = notification['title'] ?? 'Thông báo';
    final message = notification['message'] ?? '';
    
    Fluttertoast.showToast(
      msg: '$title\n$message',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 5,
      backgroundColor: const Color(0xFF246BFF),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
