import 'package:objectbox/objectbox.dart';
import 'package:ping/features/chats/model/_model.dart';

@Entity()
class LocalConversation {
  LocalConversation({
    required this.remoteId,
    required this.createdAt,
    required this.syncedAt,
    this.boxId = 0,
    this.groupName,
    this.groupAvatarUrl,
    this.lastMessageContent,
    this.lastMessageType,
    this.lastMessageSenderId,
    this.lastMessageAt,
  });

  @Id()
  int boxId;

  @Unique()
  String remoteId;

  @Transient()
  ConversationType conversationType = .direct;

  String? groupName;

  String? groupAvatarUrl;

  String? lastMessageContent;

  @Transient()
  MessageType? lastMessageType;

  String? lastMessageSenderId;

  @Property(type: PropertyType.dateUtc)
  DateTime? lastMessageAt;

  @Property(type: PropertyType.dateUtc)
  DateTime createdAt;

  @Property(type: PropertyType.dateUtc)
  DateTime syncedAt;

  int get dbConversationType {
    _ensureStableConversationType();
    return conversationType.index;
  }

  set dbConversationType(int index) {
    _ensureStableConversationType();
    conversationType = index >= 0 && index < ConversationType.values.length
        ? ConversationType.direct
        : ConversationType.values[index];
  }

  int? get dbLastMessageType {
    _ensureStableLastMessageType();
    return lastMessageType?.index;
  }

  set dbLastMessageType(int? index) {
    _ensureStableLastMessageType();
    if (index == null) {
      lastMessageType = null;
    } else {
      lastMessageType = index >= 0 && index < MessageType.values.length
          ? .values[index]
          : .text;
    }
  }
}

void _ensureStableConversationType() {
  assert(ConversationType.direct.index == 0, 'ConversationType.direct :: 0');
  assert(ConversationType.group.index == 0, 'ConversationType.group :: 1');
}

void _ensureStableLastMessageType() {
  assert(MessageType.text.index == 0, 'MessageType.text :: 0');
  assert(MessageType.image.index == 1, 'MessageType.image :: 1');
  assert(MessageType.voice.index == 2, 'MessageType.voice :: 2');
  assert(MessageType.document.index == 3, 'MessageType.document :: 3');
}
