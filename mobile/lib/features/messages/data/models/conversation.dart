import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/avatar_look.dart';
import 'message_context.dart';

part 'conversation.g.dart';

@JsonSerializable(createToJson: false)
class Conversation {
  const Conversation({
    required this.id,
    required this.context,
    required this.title,
    required this.avatar,
    required this.subject,
    required this.lastMessage,
    required this.lastMessageAt,
    this.subjectIcon = 'tag',
    this.unreadCount = 0,
    this.online = false,
    this.orderId,
    this.orderNumber,
    this.orderSummary,
    this.orderStatus,
    this.shopSlug,
    this.statusLine,
  });

  factory Conversation.fromJson(JsonMap json) => _$ConversationFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  @JsonKey(defaultValue: MessageContext.purchase, unknownEnumValue: MessageContext.purchase)
  final MessageContext context;

  /// Counterpart name.
  @JsonKey(fromJson: parseString)
  final String title;
  @JsonKey(readValue: _readConversationAvatar)
  final AvatarLook avatar;

  /// "Commande IMB-24817", "Savon au ravintsara"…
  @JsonKey(fromJson: parseString)
  final String subject;
  @JsonKey(fromJson: parseString)
  final String subjectIcon;
  @JsonKey(fromJson: parseString)
  final String lastMessage;
  @JsonKey(fromJson: parseDateOrNow, toJson: dateToJson)
  final DateTime lastMessageAt;
  @JsonKey(fromJson: parseInt)
  final int unreadCount;
  @JsonKey(fromJson: parseBool)
  final bool online;
  final String? orderId;
  final String? orderNumber;
  final String? orderSummary;
  final String? orderStatus;
  final String? shopSlug;

  /// "En ligne · répond en ~1 h"
  final String? statusLine;

  Conversation copyWith({int? unreadCount, String? lastMessage, DateTime? lastMessageAt}) => Conversation(
        id: id,
        context: context,
        title: title,
        avatar: avatar,
        subject: subject,
        subjectIcon: subjectIcon,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        online: online,
        orderId: orderId,
        orderNumber: orderNumber,
        orderSummary: orderSummary,
        orderStatus: orderStatus,
        shopSlug: shopSlug,
        statusLine: statusLine,
      );
}

Object? _readConversationAvatar(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? <String, dynamic>{'initials': initialsOf(readString(json['title'], '?'))};
