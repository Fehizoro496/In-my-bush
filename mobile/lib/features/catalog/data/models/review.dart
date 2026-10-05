import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/avatar_look.dart';

part 'review.g.dart';

/// Review (`reviews`).
@JsonSerializable()
class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.authorName,
    required this.createdAt,
    this.productId = '',
    this.productName = '',
    this.orderId,
    this.author = const AvatarLook(initials: '?'),
    this.sellerReply,
    this.repliedAt,
    this.verifiedPurchase = true,
  });

  factory Review.fromJson(JsonMap json) => _$ReviewFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  @JsonKey(fromJson: parseString)
  final String productId;
  @JsonKey(fromJson: parseString)
  final String productName;
  final String? orderId;
  @JsonKey(defaultValue: 5, fromJson: parseInt)
  final int rating;
  @JsonKey(fromJson: parseString)
  final String comment;
  @JsonKey(defaultValue: 'Client', fromJson: parseString)
  final String authorName;
  @JsonKey(readValue: _readReviewAuthor)
  final AvatarLook author;
  final String? sellerReply;
  @JsonKey(fromJson: parseDate, toJson: dateToJson)
  final DateTime? repliedAt;
  @JsonKey(fromJson: parseDateOrNow, toJson: dateToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: parseBool)
  final bool verifiedPurchase;

  Review copyWith({String? sellerReply}) => Review(
        id: id,
        productId: productId,
        productName: productName,
        orderId: orderId,
        rating: rating,
        comment: comment,
        authorName: authorName,
        author: author,
        sellerReply: sellerReply ?? this.sellerReply,
        repliedAt: sellerReply != null ? DateTime.now() : repliedAt,
        createdAt: createdAt,
        verifiedPurchase: verifiedPurchase,
      );

  JsonMap toJson() => _$ReviewToJson(this);
}

Object? _readReviewAuthor(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? <String, dynamic>{'initials': initialsOf(readString(json['authorName'], 'Client'))};
