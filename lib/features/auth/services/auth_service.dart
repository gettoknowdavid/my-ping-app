import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/model/_model.dart';

@Singleton(dependsOn: [DatabaseService])
class AuthService {
  AuthService(this._db);

  final DatabaseService _db;

  Session? get currentSession => _db.auth.currentSession;

  // Sends OTP to phone number
  Future<void> sendOtp(String phone) async {
    try {
      await _db.auth.signInWithOtp(phone: phone);
    } on AuthApiException catch (error, stackTrace) {
      log('AuthService', error: error, stackTrace: stackTrace);
      throw PingException.auth(error);
    } on AuthException catch (error, stackTrace) {
      log('AuthService', error: error, stackTrace: stackTrace);
      throw PingException.auth(error);
    }
  }

  // Create the new profile
  Future<Profile> createProfile(NewProfileArgs args) async {
    try {
      final userId = args.userId;

      String? avatarUrl;
      if (args.avatar != null) {
        avatarUrl = await uploadAvatar(userId: userId, file: args.avatar!);
      }

      final data = Profile.update(
        id: userId,
        phone: _db.auth.currentUser!.phone!,
        displayName: args.displayName,
        // avatarUrl: avatarUrl,
      );

      final response = await _db
          .from('profile')
          .update(data)
          .eq('id', userId)
          .select()
          .single();
      return Profile.fromJson(response);
    } on AuthApiException catch (error, stackTrace) {
      log('AuthService', error: error, stackTrace: stackTrace);
      throw PingException.auth(error);
    } on AuthException catch (error, stackTrace) {
      log('AuthService', error: error, stackTrace: stackTrace);
      throw PingException.auth(error);
    } on Exception catch (error, stackTrace) {
      log('AuthService', error: error, stackTrace: stackTrace);
      throw PingException.auth(error);
    }
  }

  // Verifies OTP — returns the Supabase Session on success
  Future<Session> verifyOtp(VerifyOtpArgs params) async {
    try {
      final response = await _db.auth.verifyOTP(
        type: OtpType.sms,
        phone: params.phone,
        token: params.otp,
      );
      final session = response.session;
      if (session == null) throw const PingException('OTP verification failed');
      return session;
    } on AuthApiException catch (error) {
      throw PingException.auth(error);
    } on AuthException catch (error) {
      throw PingException.auth(error);
    }
  }

  // Fetches profile for a given userId — returns null if onboarding incomplete
  Future<Profile?> fetchProfile(String userId) async {
    try {
      final response = await _db
          .from('profiles')
          .select()
          .eq(Profile.cId, userId)
          .maybeSingle();
      if (response == null) return null;
      return Profile.fromJson(response);
    } on AuthApiException catch (error) {
      throw PingException.auth(error);
    } on AuthException catch (error) {
      throw PingException.auth(error);
    }
  }

  // Uploads avatar to Supabase Storage — returns the public URL
  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    try {
      final ext = file.path.split('.').last;
      final path = '$userId/avatar.$ext';
      log('PATH: $path');

      String response;
      if (kIsWeb) {
        final avatarFile = await file.readAsBytes();
        response = await _db.storage.avatars.uploadBinary(path, avatarFile);
      } else {
        response = await _db.storage.avatars.upload(path, file);
      }

      return _db.storage.avatars.getPublicUrl(response);
    } on AuthApiException catch (error, stackTrace) {
      log('AuthService', error: error, stackTrace: stackTrace);
      throw PingException.auth(error);
    } on AuthException catch (error, stackTrace) {
      log('AuthService', error: error, stackTrace: stackTrace);
      throw PingException.auth(error);
    } on Exception catch (error, stackTrace) {
      log('AuthService', error: error, stackTrace: stackTrace);
      throw PingException.auth(error);
    }
  }

  // Signs out — clears the Supabase session
  Future<void> signOut() => _db.auth.signOut();

  // Stream of Supabase auth events — AuthManager listens to this
  Stream<AuthStatus> get authStatusChanges {
    return _db.auth.onAuthStateChange.asyncMap((data) async {
      final event = data.event;
      final session = data.session;

      if (event == .signedIn) {
        if (session == null) return const .unauthenticated();
        final profile = await fetchProfile(session.user.id);
        if (profile == null) return .onboarding(session.user.id);
        if (profile.displayName == null) return .onboarding(session.user.id);
        return AuthStatus.authenticated(profile);
      }

      if (event == .tokenRefreshed || event == .userUpdated) {
        if (session == null) return const .unauthenticated();
        final profile = await fetchProfile(session.user.id);
        if (profile?.displayName == null) return .onboarding(session.user.id);
        return AuthStatus.authenticated(profile!);
      }

      if (event == .signedOut) return const .unauthenticated();

      return const AuthStatus.unauthenticated();
    });
  }
}
