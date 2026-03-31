import 'dart:developer';
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
    } on PostgrestException catch (error, stackTrace) {
      log('ProfileService', error: error, stackTrace: stackTrace);
      throw PingException(error.message);
    } on Exception catch (error, stackTrace) {
      log('ProfileService', error: error, stackTrace: stackTrace);
      throw PingException(error.message);
    }
  }

  Future<Profile> updateDisplayName(String displayName) async {
    try {
      final data = {'display_name': displayName};
      return _db.updateProfile(_id, data: data);
    } on PostgrestException catch (error, stackTrace) {
      log('ProfileService', error: error, stackTrace: stackTrace);
      throw PingException(error.message);
    } on Exception catch (error, stackTrace) {
      log('ProfileService', error: error, stackTrace: stackTrace);
      throw PingException(error.message);
    }
  }

  Future<Profile> updateAvatar(File avatar) async {
    try {
      final avatarUrl = await _db.uploadAvatar(_id, avatar: avatar);
      return _db.updateProfile(_id, data: {'avatar_url': avatarUrl});
    } on StorageException catch (error, stackTrace) {
      log('AuthService.uploadAvatar', error: error, stackTrace: stackTrace);
      throw PingException(error.message);
    } on PostgrestException catch (error, stackTrace) {
      log('ProfileService', error: error, stackTrace: stackTrace);
      throw PingException(error.message);
    } on Exception catch (error, stackTrace) {
      log('ProfileService', error: error, stackTrace: stackTrace);
      throw PingException(error.message);
    }
  }
}
