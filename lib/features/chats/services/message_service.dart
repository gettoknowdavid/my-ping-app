import 'dart:developer';

import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/chats/model/_model.dart';

class MessageService {
  const MessageService(this._db);

  final RemoteService _db;

  /// Fetch paginated messages for a conversation newest first, cursor-based
  /// pagination
  Future<List<Message>> fetchMessages(
    String conversationId, {
    int limit = 30,
    String? beforeId, // cursor — fetch messages older than this id
  }) async {
    try {
      // Resolve cursor timestamp first if needed
      String? cursorTimestamp;
      if (beforeId != null) {
        final cursorMessage = await _db.client
            .from(Message.tableName)
            .select(Message.cCreatedAt)
            .eq(Message.cId, beforeId)
            .single();
        cursorTimestamp = cursorMessage[Message.cCreatedAt] as String;
      }

      // Build the full query — filters before transforms
      var query = _db.messages.select().eq(
        Message.cConversationId,
        conversationId,
      );

      // Apply cursor filter while still a PostgrestFilterBuilder
      if (cursorTimestamp != null) {
        query = query.lt(Message.cCreatedAt, cursorTimestamp);
      }

      // Transforms last
      final response = await query
          .order(Message.cCreatedAt, ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, Object?>))
          .toList();
    } on PostgrestException catch (e) {
      log('MESSAGE SERVICE: PostgrestException', error: e);
      throw PingException(e.message);
    } on Exception catch (e) {
      log('MESSAGE SERVICE: Exception', error: e);
      throw PingException(e.toString());
    }
  }

  /// Send a text message
  Future<Message> sendTextMessage({
    required String conversationId,
    required String content,
    String? replyToId,
  }) async {
    try {
      final data = <String, dynamic>{};
      data[Message.cConversationId] = conversationId;
      data[Message.cSenderId] = _db.client.auth.currentUser!.id;
      data[Message.cType] = MessageType.text.name;
      data['content'] = content;
      if (replyToId != null) data[Message.cReplyToId] = replyToId;

      final response = await _db.messages.insert(data).select().single();

      return Message.fromJson(response);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Send a media message (image, voice, document)
  Future<Message> sendMediaMessage({
    required String conversationId,
    required MessageType type,
    required String mediaUrl,
    String? caption,
    String? mediaName,
    int? mediaSize,
    String? replyToId,
  }) async {
    try {
      final data = <String, dynamic>{};
      data[Message.cSenderId] = _db.client.auth.currentUser!.id;
      data[Message.cConversationId] = conversationId;
      data[Conversation.cType] = type.name;
      data[Message.cMediaUrl] = mediaUrl;
      if (caption != null) data['content'] = caption;
      if (mediaName != null) data[Message.cMediaName] = mediaName;
      if (mediaSize != null) data[Message.cMediaSize] = mediaSize;
      if (replyToId != null) data[Message.cReplyToId] = replyToId;

      final response = await _db.messages.insert(data).select().single();

      return Message.fromJson(response);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Soft delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _db.messages
          .update({
            'is_deleted': true,
            'deleted_at': DateTime.now().toUtc().toIso8601String(),
            'content': null,
            'media_url': null,
          })
          .eq(Message.cId, messageId);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Mark a message as delivered for the current user
  Future<void> markDelivered(String messageId) async {
    try {
      await _db.messageReceipts.upsert({
        MessageReceipt.cMessageId: messageId,
        MessageReceipt.cProfileId: _db.client.auth.currentUser!.id,
        MessageReceipt.cDeliveredAt: DateTime.now().toUtc().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Mark a message as read for the current user
  Future<void> markRead(String messageId) async {
    try {
      await _db.messageReceipts.upsert({
        MessageReceipt.cMessageId: messageId,
        MessageReceipt.cProfileId: _db.client.auth.currentUser!.id,
        MessageReceipt.cDeliveredAt: DateTime.now().toUtc().toIso8601String(),
        MessageReceipt.cReadAt: DateTime.now().toUtc().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    } on Exception catch (e) {
      throw PingException(e.toString());
    }
  }

  /// Realtime subscription for new messages in a conversation.
  ///
  /// Returns the channel — caller must call .unsubscribe() when done
  RealtimeChannel subscribeToMessages({
    required String conversationId,
    required void Function(Message) onInsert,
    required void Function(Message) onUpdate,
  }) {
    final filter = PostgresChangeFilter(
      type: .eq,
      column: Message.cConversationId,
      value: conversationId,
    );

    return _db.client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: .insert,
          schema: 'public',
          table: Message.tableName,
          filter: filter,
          callback: (payload) => onInsert(Message.fromJson(payload.newRecord)),
        )
        .onPostgresChanges(
          event: .update,
          schema: 'public',
          table: Message.tableName,
          filter: filter,
          callback: (payload) => onUpdate(Message.fromJson(payload.newRecord)),
        )
        .subscribe();
  }

  /// Realtime subscription for receipt updates
  RealtimeChannel subscribeToReceipts({
    required String conversationId,
    required void Function(MessageReceipt) onUpdate,
  }) {
    return _db.client
        .channel('receipts:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: MessageReceipt.tableName,
          callback: (payload) => onUpdate(
            MessageReceipt.fromJson(payload.newRecord),
          ),
        )
        .subscribe();
  }
}
