import 'package:ping/_ping.dart';
import 'package:ping/features/auth/model/profile.dart';
import 'package:ping/features/chats/model/_model.dart';

class ConversationProxy extends ChangeNotifier {
  ConversationProxy({
    required ConversationListItemModel target,
    this.otherProfile,
  }) : _target = target;

  ConversationListItemModel _target;
  final Profile? otherProfile;

  ConversationListItemModel get target => _target;

  set target(ConversationListItemModel value) {
    _target = value;
    notifyListeners();
  }

  // The name shown in the conversation list row
  String get displayName => switch (_target.type) {
    .group => _target.groupName ?? 'Group',
    .direct => otherProfile?.displayName ?? otherProfile?.phone ?? 'Unknown',
  };

  // The avatar URL shown in the row
  String? get avatarUrl => switch (_target.type) {
    .group => _target.groupAvatarUrl,
    .direct => otherProfile?.avatarUrl,
  };

  bool get _isGroup => _target.type == .group;

  // The last message preview text
  String get lastMessagePreview {
    if (_target.lastMessageDeleted ?? false) return 'This message was deleted';
    if (_target.lastMessageContent == null && _target.lastMessageType == null) {
      return 'No messages yet';
    }

    final prefix = _isGroup && _target.lastMessageSenderName != null
        ? '${_target.lastMessageSenderName}: '
        : '';

    return switch (_target.lastMessageType) {
      .text => '$prefix${_target.lastMessageContent ?? ''}',
      .image => '$prefix📷 Photo',
      .voice => '$prefix🎤 Voice note',
      .document => '$prefix📄 ${_target.lastMessageContent ?? 'Document'}',
      _ => '',
    };
  }

  // Formatted timestamp for the row (today = time, older = date)
  String get formattedTime {
    final at = _target.lastMessageAt;
    if (at == null) return '';

    final n = DateTime.now(); // Current time
    final l = at.toLocal(); // The time of message in local timezone

    if (l.day == n.day && l.month == n.month && l.year == n.year) {
      // If it is today — show time
      final h = l.hour.toString().padLeft(2, '0');
      final m = l.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    // If older — show date
    return '${l.day}/${l.month}/${l.year}';
  }
}
