import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';

part 'chat_message.g.dart';

@JsonSerializable(createToJson: false)
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.body,
    required this.mine,
    required this.createdAt,
    this.read = true,
    this.senderId = '',
  });

  factory ChatMessage.fromJson(JsonMap json) => _$ChatMessageFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;

  @JsonKey(fromJson: parseString)
  final String body;

  /// Sent by the signed-in user (see [sentBy]: the API only gives `senderId`).
  @JsonKey(defaultValue: false, fromJson: parseBool)
  final bool mine;
  @JsonKey(fromJson: parseDateOrNow, toJson: dateToJson)
  final DateTime createdAt;

  @JsonKey(readValue: _readMessageRead, fromJson: parseBool)
  final bool read;
  @JsonKey(fromJson: parseString)
  final String senderId;

  /// Same message, flagged as [mine] when it was sent by [userId].
  ChatMessage sentBy(String userId) => ChatMessage(
        id: id,
        body: body,
        mine: mine || senderId == userId,
        createdAt: createdAt,
        read: read,
        senderId: senderId,
      );
}

/// A message is read once it has a `readAt` timestamp.
Object? _readMessageRead(Map<dynamic, dynamic> json, String key) => json[key] ?? json['readAt'] != null;
