import 'dart:async';

import 'package:ping/_ping.dart';
import 'package:ping/features/auth/services/auth_service.dart';
import 'package:ping/features/chats/model/_model.dart';
import 'package:ping/features/chats/services/_services.dart';

class MessageProxy extends ChangeNotifier with Disposable {
  MessageProxy(this._target, {this.replyTarget}) {
    deleteCommand = .createUndoableNoParamNoResult<bool>(
      (undoStack) async {
        undoStack.push(_isDeletedOverride ?? _target.isDeleted);
        _isDeletedOverride = true;
        notifyListeners();
        await di<MessageService>().deleteMessage(_target.id);
      },
      undo: (undoStack, reason) {
        _isDeletedOverride = undoStack.pop();
        notifyListeners();
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );
  }

  Message _target;
  final MessageProxy? replyTarget;

  Message get target => _target;

  set target(Message value) {
    _isDeletedOverride = null;
    _target = value;
    notifyListeners();
  }

  bool? _isDeletedOverride;

  String get id => _target.id;

  String get senderId => _target.senderId;

  MessageType get type => _target.type;

  DateTime get createdAt => _target.createdAt;

  bool get isDeleted => _isDeletedOverride ?? _target.isDeleted;

  String? get content => isDeleted ? null : _target.content;

  String? get mediaUrl => isDeleted ? null : _target.mediaUrl;

  String? get mediaName => _target.mediaName;

  int? get mediaSize => _target.mediaSize?.toInt();

  String? get replyToId => _target.replyToId;

  bool get isMine => senderId == di<AuthService>().activeUserId;

  // What to show in the bubble
  String get displayText {
    if (isDeleted) return 'This message was deleted';
    return switch (type) {
      MessageType.text => content ?? '',
      MessageType.image => '📷 Photo',
      MessageType.voice => '🎤 Voice note',
      MessageType.document => '📄 ${mediaName ?? 'Document'}',
    };
  }

  // Formatted time for the bubble corner
  String get formattedTime {
    final local = createdAt.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  late final Command<void, void> deleteCommand;

  @override
  FutureOr<dynamic> onDispose() {
    deleteCommand.dispose();
    super.dispose();
  }
}
