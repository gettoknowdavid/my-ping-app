import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ping/features/chats/model/_model.dart';

part 'conversation_list_item_model.freezed.dart';

part 'conversation_list_item_model.g.dart';

@Freezed(toJson: false)
abstract class ConversationListItemModel with _$ConversationListItemModel {
  const factory ConversationListItemModel({
    required String id,
    @JsonKey(name: 'conversation_type') required ConversationType type,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'group_name') String? groupName,
    @JsonKey(name: 'group_avatar_url') String? groupAvatarUrl,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'last_message_id') String? lastMessageId,
    @JsonKey(name: 'last_message_type') MessageType? lastMessageType,
    @JsonKey(name: 'last_message_content') String? lastMessageContent,
    @JsonKey(name: 'last_message_deleted') bool? lastMessageDeleted,
    @JsonKey(name: 'last_message_sender_id') String? lastMessageSenderId,
    @JsonKey(name: 'last_message_sender_name') String? lastMessageSenderName,
    @JsonKey(name: 'last_read_at') DateTime? lastReadAt,
  }) = _ConversationListItemModel;

  factory ConversationListItemModel.fromJson(Map<String, Object?> json) =>
      _$ConversationListItemModelFromJson(json);
}
