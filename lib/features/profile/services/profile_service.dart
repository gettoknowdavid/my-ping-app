import 'dart:io' show File;

import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/model/_model.dart';

class ProfileService {
  ProfileService({required DatabaseService db, required String userId})
    : _db = db,
      _id = userId;

  final DatabaseService _db;
  final String _id;

  Future<Profile?> fetchProfile(String userId) async {
    try {
      final response = await _db.profiles
          .select()
          .eq(Profile.cId, userId)
          .maybeSingle();
      if (response == null) return null;
      return Profile.fromJson(response);
    } on PostgrestException catch (error) {
      throw PingException(error.message);
    } on Exception catch (error) {
      throw PingException(error.message);
    }
  }

  Future<Profile> updateProfile({String? displayName, String? about}) async {
    try {
      const data = <String, dynamic>{};
      if (data.isEmpty) throw const PingException('No fields selected');

      if (displayName != null) data[Profile.cDisplayName] = displayName;
      if (about != null) data[Profile.cAbout] = about;

      return _db.updateProfile(_id, data: data);
    } on PostgrestException catch (error) {
      throw PingException(error.message);
    } on Exception catch (error) {
      throw PingException(error.message);
    }
  }

  // Upload avatar — moved from AuthService
  Future<String> uploadAvatar(File file) async {
    try {
      final ext = file.path.split('.').last;
      final path = '$_id/avatar.$ext';
      const fileOptions = FileOptions(upsert: true);

      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await _db.avatars.uploadBinary(path, bytes, fileOptions: fileOptions);
      } else {
        await _db.avatars.upload(path, file, fileOptions: fileOptions);
      }

      return _db.avatars.getPublicUrl(path);
    } on StorageException catch (e) {
      throw PingException(e.message);
    }
  }

  Future<Profile> updateAvatarUrl(String url) async {
    try {
      final data = {Profile.cAvatarUrl: url};
      return _db.updateProfile(_id, data: data);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    }
  }
}
