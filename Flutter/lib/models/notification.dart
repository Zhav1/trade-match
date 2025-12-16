enum NotificationType {
  newSwap,
  newMessage,
  swapStatusChange,
  system,
}

class AppNotification {
  final int id;
  final int userId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      type: _parseNotificationType(json['type']),
      title: json['title'],
      message: json['message'],
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static NotificationType _parseNotificationType(String typeString) {
    switch (typeString) {
      case 'new_swap':
        return NotificationType.newSwap;
      case 'new_message':
        return NotificationType.newMessage;
      case 'swap_status_change':
        return NotificationType.swapStatusChange;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}
