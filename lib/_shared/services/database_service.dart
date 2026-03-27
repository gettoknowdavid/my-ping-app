import 'package:ping/_core/env.dart';
import 'package:ping/_ping.dart';

@Singleton()
class DatabaseService {
  DatabaseService();

  late final SupabaseClient _client;

  @PostConstruct(preResolve: true)
  Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabasePublishableKey,
    );
    _client = Supabase.instance.client;
  }

  GoTrueClient get auth => _client.auth;
  SupabaseStorageClient get storage => _client.storage;
  SupabaseQueryBuilder from(String table) => _client.from(table);
}
