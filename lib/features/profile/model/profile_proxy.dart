import 'dart:async';
import 'dart:io' show File;

import 'package:ping/_ping.dart';
import 'package:ping/features/auth/model/_model.dart';
import 'package:ping/features/profile/services/_services.dart';

class ProfileProxy extends ChangeNotifier implements Disposable {
  ProfileProxy(this._target) {
    updateDisplayNameCommand = .createUndoableNoResult<String, String?>(
      (name, undoStack) async {
        undoStack.push(_displayNameOverride ?? _target.displayName);
        _displayNameOverride = name;
        notifyListeners();

        await di<ProfileService>().updateProfile(displayName: name);
      },
      undo: (undoStack, _) {
        _displayNameOverride = undoStack.pop();
        notifyListeners();
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );
    updateAboutCommand = .createUndoableNoResult<String, String?>(
      (about, undoStack) async {
        undoStack.push(_aboutOverride ?? _target.about);
        _aboutOverride = about;
        notifyListeners();

        await di<ProfileService>().updateProfile(about: about);
      },
      undo: (undoStack, _) {
        _aboutOverride = undoStack.pop();
        notifyListeners();
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );
    updateAvatarCommand = .createUndoableNoResult<File, String?>(
      (file, undoStack) async {
        undoStack.push(_avatarUrlOverride ?? _target.about);
        _avatarUrlOverride = file.path;
        notifyListeners();

        final avatarUrl = await di<ProfileService>().uploadAvatar(file);
        _avatarUrlOverride = avatarUrl;
        notifyListeners();

        await di<ProfileService>().updateAvatarUrl(avatarUrl);
      },
      undo: (undoStack, _) {
        _avatarUrlOverride = undoStack.pop();
        notifyListeners();
      },
      errorFilter: const GlobalIfNoLocalErrorFilter(),
    );
  }

  Profile _target;
  String? _displayNameOverride;
  String? _aboutOverride;
  String? _avatarUrlOverride;

  late final Command<String, void> updateDisplayNameCommand;
  late final Command<String, void> updateAboutCommand;
  late final Command<File, void> updateAvatarCommand;

  Profile get profile => _target;

  String get id => _target.id;

  String get phone => _target.phone;

  String get displayName => _displayNameOverride ?? _target.displayName ?? '';

  String get about => _aboutOverride ?? _target.about ?? '';

  String? get avatarUrl => _avatarUrlOverride ?? _target.avatarUrl;

  bool get hasChanges =>
      _displayNameOverride != null ||
      _aboutOverride != null ||
      _avatarUrlOverride != null;

  set profile(Profile value) {
    _target = value;
    _displayNameOverride = null;
    _aboutOverride = null;
    _avatarUrlOverride = null;
    notifyListeners();
  }

  @override
  FutureOr<dynamic> onDispose() {
    updateDisplayNameCommand.dispose();
    updateAboutCommand.dispose();
    updateAvatarCommand.dispose();
    super.dispose();
  }
}
