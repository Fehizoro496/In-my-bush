// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: parseString(json['id']),
  body: parseString(json['body']),
  mine: json['mine'] == null ? false : parseBool(json['mine']),
  createdAt: parseDateOrNow(json['createdAt']),
  read: _readMessageRead(json, 'read') == null
      ? true
      : parseBool(_readMessageRead(json, 'read')),
  senderId: json['senderId'] == null ? '' : parseString(json['senderId']),
);
