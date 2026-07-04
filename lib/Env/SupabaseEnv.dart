// Supabase project configuration.
//
// The URL + anon key are NOT secrets — they're meant to be shipped in
// the client app. Row-Level Security (RLS) policies in Postgres
// enforce that a user can only read/write their own data; the anon
// key alone grants no privileges beyond what those policies allow.
//
// For local development: copy `supabase/config.example.toml` into
// `supabase/config.toml`, run `supabase start`, and override the
// values below via `--dart-define=SUPABASE_URL=...`.
//
// For production: set the dart-define values in your CI build matrix
// (Codemagic, GitHub Actions, etc.) and never commit the real keys.

/// Supabase project URL. Override with --dart-define=SUPABASE_URL=...
const String kSupabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://YOUR-PROJECT-REF.supabase.co',
);

/// Supabase anon (public) key. Override with
/// --dart-define=SUPABASE_ANON_KEY=...
const String kSupabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'YOUR-ANON-KEY',
);

/// True when the defaults haven't been overridden — i.e. the app is
/// running without a real Supabase project configured. Useful for
/// short-circuiting network calls in tests.
const bool kSupabaseConfigured =
    !kSupabaseUrl.startsWith('https://YOUR-PROJECT-REF') &&
        !kSupabaseAnonKey.startsWith('YOUR-ANON-KEY');
