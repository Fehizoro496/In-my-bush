// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: parseString(json['id']),
  rating: json['rating'] == null ? 5 : parseInt(json['rating']),
  comment: parseString(json['comment']),
  authorName: json['authorName'] == null
      ? 'Client'
      : parseString(json['authorName']),
  createdAt: parseDateOrNow(json['createdAt']),
  productId: json['productId'] == null ? '' : parseString(json['productId']),
  productName: json['productName'] == null
      ? ''
      : parseString(json['productName']),
  orderId: json['orderId'] as String?,
  author: _readReviewAuthor(json, 'author') == null
      ? const AvatarLook(initials: '?')
      : AvatarLook.fromJson(
          _readReviewAuthor(json, 'author') as Map<String, dynamic>,
        ),
  sellerReply: json['sellerReply'] as String?,
  repliedAt: parseDate(json['repliedAt']),
  verifiedPurchase: json['verifiedPurchase'] == null
      ? true
      : parseBool(json['verifiedPurchase']),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'productName': instance.productName,
  'orderId': ?instance.orderId,
  'rating': instance.rating,
  'comment': instance.comment,
  'authorName': instance.authorName,
  'author': instance.author.toJson(),
  'sellerReply': ?instance.sellerReply,
  'repliedAt': ?dateToJson(instance.repliedAt),
  'createdAt': ?dateToJson(instance.createdAt),
  'verifiedPurchase': instance.verifiedPurchase,
};
