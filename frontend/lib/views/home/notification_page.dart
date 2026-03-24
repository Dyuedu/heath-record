import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/notification_viewmodel.dart';
import 'package:frontend/views/medical-record/single_record_detail_page.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationVM = context.watch<NotificationViewModel>();
    final notifications = notificationVM.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Color(0xFF1F2A44),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2A44)),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa có thông báo nào.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return GestureDetector(
                  onTap: () {
                    if (!notif.isRead) {
                      notificationVM.markAsRead(notif.id);
                    }
                    if (notif.recordId != null && notif.recordId!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SingleRecordDetailPage(recordId: notif.recordId!),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: notif.isRead ? Colors.white : const Color(0xFFE8F1FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notif.isRead ? const Color(0xFFE3E8FF) : const Color(0xFF246BFF).withOpacity(0.3),
                      ),
                      boxShadow: notif.isRead
                          ? []
                          : [
                              BoxShadow(
                                color: const Color(0xFF246BFF).withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: notif.isRead ? const Color(0xFFF5F6F9) : const Color(0xFF246BFF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.medical_information_rounded,
                            color: notif.isRead ? Colors.grey : Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                                  fontSize: 16,
                                  color: notif.isRead ? Colors.black54 : const Color(0xFF1F2A44),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                notif.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: notif.isRead ? Colors.black45 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatDuration(notif.timestamp),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDuration(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
