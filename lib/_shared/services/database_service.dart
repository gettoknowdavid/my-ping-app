import 'package:ping/_core/env.dart';
import 'package:ping/_ping.dart';

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
}
