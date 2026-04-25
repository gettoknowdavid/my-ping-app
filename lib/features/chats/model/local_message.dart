import 'package:objectbox/objectbox.dart';
import 'package:ping/features/chats/model/_model.dart';

@Entity()
class LocalMessage {
  LocalMessage({
    required this.remoteId,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.createdAt,
    required this.syncedAt,
    this.boxId = 0,
    this.isDeleted = false,
    this.isFailed = false,
    this.isPending = false,
    this.content,
    this.mediaUrl,
    this.mediaName,
    this.mediaSize,
    this.replyToId,
  });

  @Id()
  int boxId;

  @Unique()
  String remoteId;

  String conversationId;

  String senderId;

  @Transient()
  MessageType type;

  bool isDeleted;

  bool isFailed;

  bool isPending;

  @Property(type: PropertyType.dateUtc)
  DateTime createdAt;

  @Property(type: PropertyType.dateUtc)
  DateTime syncedAt;

  String? content;

  String? mediaUrl;

  String? mediaName;

  int? mediaSize;

  String? replyToId;

  int get dbMessageType {
    _ensureStableMessageType();
    return type.index;
  }

  set dbMessageType(int index) {
    _ensureStableMessageType();
    type = index >= 0 && index < MessageType.values.length
        ? .values[index]
        : .text;
  }
}

void _ensureStableMessageType() {
  assert(MessageType.text.index == 0, 'MessageType.text :: 0');
  assert(MessageType.image.index == 1, 'MessageType.image :: 1');
  assert(MessageType.voice.index == 2, 'MessageType.voice :: 2');
  assert(MessageType.document.index == 3, 'MessageType.document :: 3');
}
