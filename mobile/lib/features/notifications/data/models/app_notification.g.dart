// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: parseString(json['id']),
      context:
          $enumDecodeNullable(
            _$NotificationContextEnumMap,
            json['context'],
            unknownValue: NotificationContext.system,
          ) ??
          NotificationContext.system,
      type: NotificationType.fromApi(json['type']),
      title: parseString(json['title']),
      body: parseString(json['body']),
      createdAt: parseDateOrNow(json['createdAt']),
      link: json['link'] as String?,
      readAt: parseDate(json['readAt']),
      cta: json['cta'] as String?,
    );

const _$NotificationContextEnumMap = {
  NotificationContext.purchase: 'PURCHASE',
  NotificationContext.sale: 'SALE',
  NotificationContext.system: 'SYSTEM',
};
