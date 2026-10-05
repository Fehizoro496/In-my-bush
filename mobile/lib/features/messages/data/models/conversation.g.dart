// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  id: parseString(json['id']),
  context:
      $enumDecodeNullable(
        _$MessageContextEnumMap,
        json['context'],
        unknownValue: MessageContext.purchase,
      ) ??
      MessageContext.purchase,
  title: parseString(json['title']),
  avatar: AvatarLook.fromJson(
    _readConversationAvatar(json, 'avatar') as Map<String, dynamic>,
  ),
  subject: parseString(json['subject']),
  lastMessage: parseString(json['lastMessage']),
  lastMessageAt: parseDateOrNow(json['lastMessageAt']),
  subjectIcon: json['subjectIcon'] == null
      ? 'tag'
      : parseString(json['subjectIcon']),
  unreadCount: json['unreadCount'] == null ? 0 : parseInt(json['unreadCount']),
  online: json['online'] == null ? false : parseBool(json['online']),
  orderId: json['orderId'] as String?,
  orderNumber: json['orderNumber'] as String?,
  orderSummary: json['orderSummary'] as String?,
  orderStatus: json['orderStatus'] as String?,
  shopSlug: json['shopSlug'] as String?,
  statusLine: json['statusLine'] as String?,
);

const _$MessageContextEnumMap = {
  MessageContext.purchase: 'PURCHASE',
  MessageContext.sale: 'SALE',
};
