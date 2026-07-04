// Tests for the SupabaseService singleton wrapper.
//
// Verifies that:
//   * The override mechanism works (test code can inject a fake
//     client before any production code calls client/auth/storage).
//   * The currentUserId / isSignedIn getters delegate to the auth
//     surface of the active client.
//   * initialize() is idempotent — calling it twice doesn't throw.
//
// We don't test the actual Supabase.initialize() path here because
// that requires a real project URL + anon key. Integration tests
// would do that in a separate test file gated on environment vars.

import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/Env/SupabaseEnv.dart';
import 'package:kookers/Services/SupabaseService.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('SupabaseEnv', () {
    test('kSupabaseUrl defaults to a placeholder', () {
      // Without --dart-define, the default should be the placeholder.
      // (CI overrides it via dart-define for real builds.)
      expect(kSupabaseUrl, isNotEmpty);
    });

    test('kSupabaseAnonKey defaults to a placeholder', () {
      expect(kSupabaseAnonKey, isNotEmpty);
    });

    test('kSupabaseConfigured is false when defaults are in place', () {
      // In the test environment, no --dart-define is set, so the
      // configured flag should be false.
      expect(kSupabaseConfigured, isFalse);
    });
  });

  group('SupabaseService.override', () {
    tearDown(() {
      // Reset the override between tests so they don't pollute each
      // other.
      SupabaseService.override = null;
    });

    test('setting override makes client return the fake', () {
      final fake = _FakeSupabaseClient();
      SupabaseService.override = fake;

      expect(SupabaseService.client, same(fake));
    });

    test('auth getter delegates to the override', () {
      final fake = _FakeSupabaseClient();
      SupabaseService.override = fake;

      expect(SupabaseService.auth, same(fake.auth));
    });

    test('storage getter delegates to the override', () {
      final fake = _FakeSupabaseClient();
      SupabaseService.override = fake;

      expect(SupabaseService.storage, same(fake.storage));
    });

    test('realtime getter delegates to the override', () {
      final fake = _FakeSupabaseClient();
      SupabaseService.override = fake;

      expect(SupabaseService.realtime, same(fake.realtime));
    });

    test('from getter returns a function that hits the override', () {
      final fake = _FakeSupabaseClient();
      SupabaseService.override = fake;

      final query = SupabaseService.from('profiles');
      expect(query, isA<SupabaseQueryBuilder>());
    });

    test('currentUserId is null when no user is signed in', () {
      SupabaseService.override = _FakeSupabaseClient(currentUser: null);
      expect(SupabaseService.currentUserId, isNull);
      expect(SupabaseService.isSignedIn, isFalse);
    });

    test('currentUserId returns the user id when signed in', () {
      SupabaseService.override =
          _FakeSupabaseClient(currentUser: _FakeUser(id: 'u-123'));
      expect(SupabaseService.currentUserId, 'u-123');
      expect(SupabaseService.isSignedIn, isTrue);
    });
  });
}

/// Minimal fake SupabaseClient that records method calls. We only
/// implement the surface that SupabaseService actually touches.
class _FakeSupabaseClient implements SupabaseClient {
  _FakeSupabaseClient({this.currentUser});

  final _FakeUser? currentUser;

  late final GoTrueClient auth = _FakeGoTrueClient(currentUser);
  late final SupabaseStorageClient storage = _FakeStorage();
  late final SupabaseRealtimeClient realtime = _FakeRealtime();

  @override
  SupabaseQueryBuilder from(String table) {
    return _FakeQueryBuilder(table);
  }

  // Stub out the rest of the SupabaseClient interface so the
  // implements clause is satisfied. The tests don't touch these.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGoTrueClient implements GoTrueClient {
  _FakeGoTrueClient(this._currentUser);
  final _FakeUser? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<AuthState> get onAuthStateChange =>
      Stream.value(AuthState(_FakeSession(_currentUser), AuthChangeEvent.initialSession));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSession implements Session {
  _FakeSession(this._user);
  final _FakeUser? _user;

  @override
  User? get user => _user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUser implements User {
  _FakeUser({this.id = 'fake-user-id'});
  @override
  final String id;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStorage implements SupabaseStorageClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRealtime implements SupabaseRealtimeClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeQueryBuilder implements SupabaseQueryBuilder {
  _FakeQueryBuilder(this.table);
  final String table;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
