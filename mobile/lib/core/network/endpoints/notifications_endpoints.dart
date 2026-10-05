/// Notifications (`/notifications`).
abstract class NotificationsEndpoints {
  static const notifications = '/notifications';
  static const readAll = '/notifications/read-all';

  static String read(String id) => '/notifications/$id/read';
}
