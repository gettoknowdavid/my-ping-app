import 'dart:io';

import 'package:ping/_core/env.dart';
import 'package:ping/_ping.dart';
import 'package:ping/features/auth/model/_model.dart';

class DatabaseService {
  DatabaseService._();

  late final SupabaseClient _client;

  static Future<DatabaseService> initialize() async {
    final service = DatabaseService._();
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabasePublishableKey,
    );
    service._client = Supabase.instance.client;

    assert(() {
      // Uncomment only when you need to force-clear local session:
      // await service._client.auth.signOut();
      return true;
    }(), 'Supabase session not cleared');

    return service;
  }

  SupabaseClient get client => _client;

  SupabaseQueryBuilder get profiles => _client.from('profiles');

  StorageFileApi get avatars => _client.storage.from('avatars');

  PostgrestBuilder<Profile, Profile, PostgrestMap> updateProfile(
    String id, {
    required Map<String, Object?> data,
  }) => profiles
      .update(data)
      .eq(Profile.cId, id)
      .select()
      .single()
      .withConverter(Profile.fromJson);

  String getAvatarUrl(String path) => avatars.getPublicUrl(path);

  Future<String> uploadAvatar(String userId, {required File avatar}) async {
    final ext = avatar.path.split('.').last;
    final path = '$userId/avatar.$ext';
    const fileOptions = FileOptions(upsert: true);

    if (kIsWeb) {
      final bytes = await avatar.readAsBytes();
      await avatars.uploadBinary(path, bytes, fileOptions: fileOptions);
    } else {
      await avatars.upload(path, avatar, fileOptions: fileOptions);
    }

    // return avatars.createSignedUrl(path, 60 * 60 * 24 * 365 * 10);
    return avatars.getPublicUrl(path);
  }
}
