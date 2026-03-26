import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/models/_models.dart';
import 'package:ping/features/auth/model/_model.dart';

@singleton
class AuthService {
  const AuthService(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  // Sends OTP to phone number
  Future<void> sendOtp(String phone) {
    return _client.auth.signInWithOtp(phone: phone);
  }

  // Create the new profile
  Future<Profile> createProfile(NewProfileParams params) async {
    final userId = params.userId;

    String? avatarUrl;
    if (params.avatar != null) {
      avatarUrl = await uploadAvatar(userId: userId, file: params.avatar!);
    }

    final data = Profile.insert(
      id: userId,
      phone: _client.auth.currentUser!.phone!,
      username: params.username,
      displayName: params.displayName,
      avatarUrl: avatarUrl,
    );

    final response = await _client.profiles.insert(data).select().single();
    return Profile.fromJson(response);
  }

  // Verifies OTP — returns the Supabase Session on success
  Future<Session> verifyOtp(VerifyOtpParams params) async {
    final response = await _client.auth.verifyOTP(
      type: OtpType.sms,
      phone: params.phone,
      token: params.otp,
    );
    final session = response.session;
    if (session == null) throw Exception('OTP verification failed');
    return session;
  }

  // Fetches profile for a given userId — returns null if onboarding incomplete
  Future<Profile?> fetchProfile(String userId) async {
    final response = await _client.profiles
        .select()
        .eq(Profile.cId, userId)
        .maybeSingle();
    if (response == null) return null;
    return Profile.fromJson(response);
  }

  // Uploads avatar to Supabase Storage — returns the public URL
  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final path = '$userId/avatar.$ext';
    const fileOptions = FileOptions(upsert: true);

    if (kIsWeb) {
      final avatarFile = await file.readAsBytes();
      await _client.storage.avatars.uploadBinary(
        path,
        avatarFile,
        fileOptions: fileOptions,
      );
    } else {
      await _client.storage.avatars.upload(
        path,
        file,
        fileOptions: fileOptions,
      );
    }

    return _client.storage.avatars.getPublicUrl(path);
  }

  // Signs out — clears the Supabase session
  Future<void> signOut() => _client.auth.signOut();

  // Stream of Supabase auth events — AuthManager listens to this
  Stream<AuthStatus> get authStatusChanges {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final event = data.event;
      final session = data.session;

      if (event == .signedIn) {
        if (session == null) return const .unauthenticated();

        final profile = await fetchProfile(session.user.id);
        if (profile == null) return .onboarding(session.user.id);
        if (profile.username == null) return .onboarding(session.user.id);

        return AuthStatus.authenticated(profile);
      }

      if (event == .tokenRefreshed || event == .userUpdated) {
        if (session == null) return const .unauthenticated();

        final profile = await fetchProfile(session.user.id);
        if (profile?.username == null) return .onboarding(session.user.id);

        return AuthStatus.authenticated(profile!);
      }

      if (event == .signedOut) return const .unauthenticated();

      return const AuthStatus.unauthenticated();
    });
  }
}
