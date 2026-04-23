import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ping/features/chats/model/message_type.dart';

part 'message.freezed.dart';

part 'message.g.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'is_deleted') required bool isDeleted,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    required MessageType type,
    String? content,
    @JsonKey(name: 'media_url') String? mediaUrl,
    @JsonKey(name: 'media_name') String? mediaName,
    @JsonKey(name: 'media_size') BigInt? mediaSize,
    @JsonKey(name: 'reply_to_id') String? replyToId,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
  }) = _Message;

  factory Message.fromJson(Map<String, Object?> json) =>
      _$MessageFromJson(json);

  static const String tableName = 'messages';
  static const String cId = 'id';
  static const String cConversationId = 'conversation_id';
  static const String cType = 'type';
  static const String cSenderId = 'sender_id';
  static const String cReplyToId = 'reply_to_id';
  static const String cMediaUrl = 'media_url';
  static const String cMediaName = 'media_name';
  static const String cMediaSize = 'media_size';
  static const String cCreatedAt = 'created_at';
}
