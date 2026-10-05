import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';

part 'review_draft.g.dart';

/// Buyer review form payload (`POST /me/orders/{id}/reviews`).
@JsonSerializable(createFactory: false)
class ReviewDraft {
  const ReviewDraft({
    required this.productId,
    required this.rating,
    this.comment = '',
    this.tags = const {},
    this.communicationRating,
    this.preparationRating,
    this.showName = true,
  });

  final String productId;
  final int rating;
  final String comment;
  final Set<String> tags;
  final int? communicationRating;
  final int? preparationRating;
  final bool showName;

  JsonMap toJson() => _$ReviewDraftToJson(this);
}
