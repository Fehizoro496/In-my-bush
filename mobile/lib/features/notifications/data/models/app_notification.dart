import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import 'notification_context.dart';
import 'notification_type.dart';

part 'app_notification.g.dart';

@JsonSerializable(createToJson: false)
class AppNotification {
  const AppNotification({
    required this.id,
    required this.context,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.link,
    this.readAt,
    this.cta,
  });

  factory AppNotification.fromJson(JsonMap json) => _$AppNotificationFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  @JsonKey(defaultValue: NotificationContext.system, unknownEnumValue: NotificationContext.system)
  final NotificationContext context;
  @JsonKey(fromJson: NotificationType.fromApi)
  final NotificationType type;
  @JsonKey(fromJson: parseString)
  final String title;
  @JsonKey(fromJson: parseString)
  final String body;

  /// In-app route (e.g. `/commandes/ord-24817-ra`).
  final String? link;
  @JsonKey(fromJson: parseDateOrNow, toJson: dateToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: parseDate, toJson: dateToJson)
  final DateTime? readAt;

  /// Inline action label ("Confirmer", "Laisser un avis").
  final String? cta;

  bool get unread => readAt == null;

  AppNotification markRead() => AppNotification(
        id: id,
        context: context,
        type: type,
        title: title,
        body: body,
        link: link,
        createdAt: createdAt,
        readAt: readAt ?? DateTime.now(),
        cta: cta,
      );
}
