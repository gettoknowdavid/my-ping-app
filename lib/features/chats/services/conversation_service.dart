import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/chats/model/_model.dart';

class ConversationService {
  const ConversationService(this._db);

  final DatabaseService _db;

  /// Fetch all conversations for the current user, ordered by most
  /// recent message
  Future<List<Conversation>> fetchConversations() async {
    try {
      final response = await _db.conversations.select().order(
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
      final response = await _db.client.rpc<dynamic>(
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
      data[Conversation.cCreatorId] = _db.client.auth.currentUser!.id;
      if (avatarUrl != null) data[Conversation.cAvatarUrl] = avatarUrl;

      final conversationResponse = await _db.conversations
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
        profileId: _db.client.auth.currentUser!.id,
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
      return _db.conversationMembers.insert(members);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Fetch members of a conversation
  Future<List<ConversationMember>> fetchMembers(String conversationId) async {
    try {
      final response = await _db.client
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
  Future<void> markAsRead(String conversationId) async {
    try {
      final lastReadAt = DateTime.now().toUtc().toIso8601String();
      final profileId = _db.client.auth.currentUser!.id;

      // Update last_read_at for current user
      await _db.client
          .from(ConversationMember.tableName)
          .update({ConversationMember.cLastReadAt: lastReadAt})
          .eq(Conversation.cId, conversationId)
          .eq(Conversation.cCreatorId, profileId);

      // Update read_at on all unread receipts
      await _db.client
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
    final profileId = _db.client.auth.currentUser!.id;
    return _db.client
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
}
