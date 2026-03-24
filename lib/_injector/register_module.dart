import 'package:ping/_core/env.dart';
import 'package:ping/_ping.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<Supabase> get supabase {
    return Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }
}
