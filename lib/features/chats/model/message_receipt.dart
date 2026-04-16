import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_receipt.freezed.dart';

part 'message_receipt.g.dart';

@Freezed(toJson: false)
abstract class MessageReceipt with _$MessageReceipt {
  const factory MessageReceipt({
    @JsonKey(name: 'message_id') required String messageId,
    @JsonKey(name: 'profile_id') required String profileId,
    @JsonKey(name: 'delivered_at') DateTime? deliveredAt,
    @JsonKey(name: 'read_at') DateTime? readAt,
  }) = _MessageReceipt;

  factory MessageReceipt.fromJson(Map<String, Object?> json) =>
      _$MessageReceiptFromJson(json);

  static const String tableName = 'message_receipts';
  static const String cMessageId = 'message_id';
  static const String cProfileId = 'profile_id';
  static const String cDeliveredAt = 'delivered_at';
  static const String cReadAt = 'read_at';
}
