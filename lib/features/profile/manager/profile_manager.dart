import 'dart:async';

import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/model/_model.dart';
import 'package:ping/features/profile/model/_model.dart';

class ProfileManager implements Disposable {
  ProfileManager({
    required Profile profile,
    required ToastManager toast,
  }) : _currentProfile = profile,
       _toast = toast;

  final Profile _currentProfile;
  final ToastManager _toast;

  late ProfileProxy profile;

  void initialize() {
    profile = ProfileProxy(_currentProfile);

    profile.updateDisplayNameCommand.errors.listen((error, _) {
      _toast.error('Could not update name. Changes reverted.');
    });
    profile.updateAboutCommand.errors.listen((error, _) {
      _toast.error('Could not update about. Changes reverted.');
    });
    profile.updateAvatarCommand.errors.listen((error, _) {
      _toast.error('Could not update avatar. Changes reverted.');
    });
  }

  @override
  FutureOr<dynamic> onDispose() async {
    await profile.onDispose();
  }
}
