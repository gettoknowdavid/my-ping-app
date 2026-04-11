import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ping/features/chats/model/conversation_type.dart';

part 'conversation.freezed.dart';

part 'conversation.g.dart';

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    @JsonKey(name: 'creator_id') required String creatorId,
    @JsonKey(name: 'conversation_type') required ConversationType type,
    @JsonKey(name: 'group_name') String? groupName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'last_message_id') String? lastMessageId,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, Object?> json) =>
      _$ConversationFromJson(json);

  static const String tableName = 'conversations';
  static const String cId = 'id';
  static const String cIsGroup = 'is_group';
  static const String cLastMessageAt = 'last_message_at';
}
