import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/model/profile.dart';
import 'package:ping/features/chats/model/_model.dart';

class ConversationService {
  const ConversationService({
    required RemoteService remote,
    required LocalService local,
  }) : _remote = remote,
       _local = local;

  final RemoteService _remote;
  final LocalService _local;

  /// Fetch all conversations for the current user, ordered by most
  /// recent message
  Future<List<Conversation>> fetchConversations() async {
    try {
      final response = await _remote.conversations.select().order(
        Conversation.cLastMessageAt,
        ascending: false,
      );
      return (response as List<dynamic>)
          .map((e) => Conversation.fromJson(e as Map<String, Object?>))
          .toList();
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Get or create a one-on-one conversation via RPC
  Future<String> getOrCreateConversation(String otherProfileId) async {
    try {
      final response = await _remote.client.rpc<dynamic>(
        'get_or_create_conversation',
        params: {'other_profile_id': otherProfileId},
      );
      return response as String;
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Create group conversation
  Future<Conversation> createGroup({
    required String groupName,
    required List<String> memberIds,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};

      data[Conversation.cGroupName] = groupName;
      data[Conversation.cType] = ConversationType.group.name;
      data[Conversation.cCreatorId] = _remote.client.auth.currentUser!.id;
      if (avatarUrl != null) data[Conversation.cAvatarUrl] = avatarUrl;

      final conversationResponse = await _remote.conversations
          .insert(data)
          .select()
          .single();

      final conversation = Conversation.fromJson(conversationResponse);

      // Insert the creator of the group as the admin and all added members
      await addMembersToGroup(conversation.id, memberIds: memberIds);

      return conversation;
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  Future<void> addMembersToGroup(
    String conversationId, {
    required List<String> memberIds,
  }) async {
    try {
      final admin = ConversationMember.admin(
        conversationId: conversationId,
        profileId: _remote.client.auth.currentUser!.id,
      );

      final otherMembers = memberIds
          .map(
            (id) => ConversationMember.member(
              conversationId: conversationId,
              profileId: id,
            ),
          )
          .toList();

      final members = [admin, ...otherMembers];
      return _remote.conversationMembers.insert(members);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Fetch members of a conversation
  Future<List<ConversationMember>> fetchMembers(String conversationId) async {
    try {
      final response = await _remote.client
          .from(ConversationMember.tableName)
          .select()
          .eq(Conversation.cId, conversationId);
      return (response as List<dynamic>)
          .map((e) => ConversationMember.fromJson(e as Map<String, Object?>))
          .toList();
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Mark all messages in a conversation as read
  Future<void> markAllAsRead(String conversationId) async {
    try {
      final lastReadAt = DateTime.now().toUtc().toIso8601String();
      final profileId = _remote.client.auth.currentUser!.id;

      // Update last_read_at for current user
      await _remote.client
          .from(ConversationMember.tableName)
          .update({ConversationMember.cLastReadAt: lastReadAt})
          .eq('conversation_id', conversationId)
          .eq('profile_id', profileId);

      // Update read_at on all unread receipts
      await _remote.client
          .from(MessageReceipt.tableName)
          .update({MessageReceipt.cReadAt: lastReadAt})
          .eq(MessageReceipt.cProfileId, profileId)
          .isFilter(MessageReceipt.cReadAt, null);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Realtime subscription for conversation list updates
  RealtimeChannel subscribeToConversations({
    required void Function(Conversation) onUpdate,
  }) {
    final profileId = _remote.client.auth.currentUser!.id;
    return _remote.client
        .channel('${Conversation.tableName}:$profileId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: Conversation.tableName,
          callback: (payload) {
            final updated = Conversation.fromJson(payload.newRecord);
            onUpdate(updated);
          },
        )
        .subscribe();
  }

  /// Fetch all items from the `conversations_list` view
  Future<List<ConversationListItemModel>> fetchConversationListItems() async {
    try {
      final response = await _remote.conversationsView.select().order(
        'last_message_at',
        ascending: false,
        nullsFirst: false,
      );

      return (response as List<dynamic>).map((e) {
        final json = e as Map<String, Object?>;
        return ConversationListItemModel.fromJson(json);
      }).toList();
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Fetch a single item from the view (for refresh after Realtime update)
  Future<ConversationListItemModel?> fetchConversationListItem(
    String conversationId,
  ) async {
    try {
      final response = await _remote.conversationsView
          .select()
          .eq('id', conversationId)
          .maybeSingle();
      if (response == null) return null;
      return ConversationListItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Fetch the other member's profile for a one-on-one conversation
  Future<Profile?> fetchOtherMemberProfile(
    String conversationId,
    String currentUserId,
  ) async {
    try {
      final response = await _remote.client
          .from(ConversationMember.tableName)
          .select('profile_id, profiles(*)')
          .eq('conversation_id', conversationId)
          .neq('profile_id', currentUserId)
          .maybeSingle();
      if (response == null) return null;
      final profileData = response['profiles'] as Map<String, dynamic>?;
      if (profileData == null) return null;
      return Profile.fromJson(profileData);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  Stream<List<ConversationListItemModel>> watchConversations() {
    return _local.watchConversations().map(
      (event) => event.map(
        (e) {
          return ConversationListItemModel(
            id: e.remoteId,
            type: e.conversationType,
            createdAt: e.createdAt,
            groupName: e.groupName,
            groupAvatarUrl: e.groupAvatarUrl,
            lastMessageAt: e.lastMessageAt,
            lastMessageContent: e.lastMessageContent,
            lastMessageSenderId: e.lastMessageSenderId,
            lastMessageType: e.lastMessageType,
          );
        },
      ).toList(),
    );
  }
}
