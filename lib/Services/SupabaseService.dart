import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kookers/Env/SupabaseEnv.dart';

/// Thin singleton wrapper around the Supabase client.
///
/// The actual [SupabaseClient] is held by [Supabase.instance] after
/// [Supabase.initialize] is called from `main()`. This class exists
/// so the rest of the codebase has a single, typed entry point and so
/// tests can swap in a fake without touching `main()`.
///
/// Usage:
///   await SupabaseService.initialize();   // in main()
///   final client = SupabaseService.client;
///   final auth = SupabaseService.auth;
///   final storage = SupabaseService.storage;
///   final realtime = SupabaseService.realtime;
///
/// In tests:
///   SupabaseService.override = _FakeClient();   // before pumpWidget
class SupabaseService {
  SupabaseService._();

  /// Set this in tests to inject a fake client. When non-null,
  /// [client] / [auth] / [storage] / [realtime] all delegate to it.
  static SupabaseClient? override;

  /// Initialise the singleton. Idempotent — calling twice is a no-op.
  /// Safe to call from `main()` before `runApp()`.
  static Future<void> initialize() async {
    if (override != null) return; // test mode
    if (Supabase.instance.client.auth.currentUser != null ||
        _initialized) {
      return;
    }
    await Supabase.initialize(
      url: kSupabaseUrl,
      anonKey: kSupabaseAnonKey,
      debug: false,
      // We do NOT enable Flutter deep-link auth here — phone-auth
      // doesn't need it, and enabling it would interfere with the
      // existing GetMaterialApp routing.
      authOptions: const AuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
    _initialized = true;
  }

  static bool _initialized = false;

  /// The active Supabase client. Returns the test override if one
  /// was set, otherwise the production singleton.
  static SupabaseClient get client {
    if (override != null) return override!;
    assert(_initialized,
        'SupabaseService.initialize() must be called before accessing client');
    return Supabase.instance.client;
  }

  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;
  static SupabaseRealtimeClient get realtime => client.realtime;
  static SupabaseQueryBuilder Function(String table) get from =>
      (table) => client.from(table);

  /// Convenience: the current user's id, or null if signed out.
  static String? get currentUserId => auth.currentUser?.id;

  /// True when there is a signed-in user.
  static bool get isSignedIn => auth.currentUser != null;
}
