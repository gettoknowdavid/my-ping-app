import 'package:ping/_ping.dart';

abstract class DbModel<T> {
  static Map<String, dynamic> insert(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  static Map<String, dynamic> update(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  static dynamic converter(List<Map<String, dynamic>> data) {
    throw UnimplementedError();
  }
}

// Supabase Client Extension
extension SupadartClient on SupabaseClient {
  SupabaseQueryBuilder get profiles => from('profiles');

  SupabaseQueryBuilder get profileCreation => from('profile_creation_audit');

  SupabaseQueryBuilder get profilesPublic => from('profiles_public');
}

// Supabase Storage Client Extension
extension SupadartStorageClient on SupabaseStorageClient {
  StorageFileApi get avatars => from('avatars');

  StorageFileApi get chatMedia => from('chat-media');
}
