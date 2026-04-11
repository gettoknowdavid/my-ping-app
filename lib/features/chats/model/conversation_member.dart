import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_member.freezed.dart';

part 'conversation_member.g.dart';

@Freezed(toJson: false)
abstract class ConversationMember with _$ConversationMember {
  const factory ConversationMember({
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'profile_id') required String profileId,
    @JsonKey(name: 'is_admin') required bool isAdmin,
    @JsonKey(name: 'joined_at') required DateTime joinedAt,
    @JsonKey(name: 'last_read_at') DateTime? lastReadAt,
  }) = _ConversationMember;

  factory ConversationMember.fromJson(Map<String, Object?> json) =>
      _$ConversationMemberFromJson(json);
}
