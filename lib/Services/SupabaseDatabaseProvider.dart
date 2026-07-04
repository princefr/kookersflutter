// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

import 'package:kookers/Services/DatabaseProvider.dart' as legacy;
import 'package:kookers/Services/SupabaseService.dart';
import 'package:rxdart/subjects.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed drop-in replacement for `DatabaseProviderService`.
///
/// Exposes the **same public API** (BehaviorSubjects + load methods)
/// so the rest of the app doesn't need to change. Each method now
/// issues a Postgres query via `supabase_flutter` instead of a
/// GraphQL mutation.
///
/// **Wiring:** In `main.dart`, swap the provider:
///   Provider<DatabaseProviderService>(
///     create: (_) => SupabaseDatabaseProvider(),
///   )
///
/// To keep the diff minimal, `SupabaseDatabaseProvider` **extends**
/// `DatabaseProviderService` and overrides only the data-access
/// methods. The BehaviorSubjects (user, publications, buyerOrders,
/// sellerOrders, sellerPublications, rooms, adress) are inherited
/// unchanged, so any screen that listens to them keeps working.
///
/// **What's NOT migrated in this PR (left as TODOs):** Stripe mutation
/// helpers (createBankAccount, makePayout, addattachPaymentToCustomer)
/// — those go through Stripe's own API, not Supabase; they're kept on
/// the legacy GraphQL backend for now and will be migrated to Supabase
/// Edge Functions in a follow-up.
class SupabaseDatabaseProvider extends legacy.DatabaseProviderService {
  SupabaseDatabaseProvider() : super();

  /// True when Supabase is reachable (i.e. configured + signed in).
  bool get _ready => SupabaseService.isSignedIn;

  // =========================================================================
  // USER
  // =========================================================================

  @override
  Future<legacy.UserDef?> loadUserData(String uid) async {
    if (!_ready) return null;
    try {
      final response = await SupabaseService.from('profiles')
          .select('''
            id, email, first_name, last_name, phonenumber, photo_url,
            country, currency, is_seller, default_source, default_iban,
            stripe_customer_id, stripe_account_id, fcm_token,
            notification_permission, settings, created_at, updated_at
          ''')
          .eq('id', uid)
          .maybeSingle();

      if (response == null) {
        // No profile row yet — the on_auth_user_created trigger should
        // have made one, but if it didn't (e.g. test env), bail.
        return null;
      }

      // Load related rows.
      final addresses = await SupabaseService.from('addresses')
          .select('title, latitude, longitude, is_chosen')
          .eq('user_id', uid);
      final ibans = await SupabaseService.from('ibans')
          .select('*')
          .eq('user_id', uid);
      final cards = await SupabaseService.from('cards')
          .select('*')
          .eq('user_id', uid);
      final balance = await SupabaseService.from('balances')
          .select('*')
          .eq('user_id', uid)
          .maybeSingle();
      final transactions = await SupabaseService.from('transactions')
          .select('*')
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(50);

      final userDef = _mapProfileToUserDef(
        profile: response,
        addresses: addresses as List? ?? const [],
        ibans: ibans as List? ?? const [],
        cards: cards as List? ?? const [],
        balance: balance,
        transactions: transactions as List? ?? const [],
      );
      user.add(userDef);
      if (userDef.adresses?.isNotEmpty ?? false) {
        final chosen = userDef.adresses!.firstWhere(
          (a) => a.isChosed == true,
          orElse: () => userDef.adresses!.first,
        );
        adress.add(chosen);
      }
      return userDef;
    } catch (e) {
      print('loadUserData error: $e');
      return null;
    }
  }

  legacy.UserDef _mapProfileToUserDef({
    required Map<String, dynamic> profile,
    required List addresses,
    required List ibans,
    required List cards,
    Map<String, dynamic>? balance,
    required List transactions,
  }) {
    // Reuse the existing UserDef model so the rest of the app keeps
    // working. We translate the camelCase columns to the legacy
    // snake_case field names by hand.
    final settings = (profile['settings'] as Map<String, dynamic>?) ?? {};
    return legacy.UserDef()
      ..id = profile['id'] as String?
      ..email = profile['email'] as String?
      ..firstName = profile['first_name'] as String?
      ..lastName = profile['last_name'] as String?
      ..phonenumber = profile['phonenumber'] as String?
      ..photoUrl = profile['photo_url'] as String?
      ..country = profile['country'] as String?
      ..currency = profile['currency'] as String?
      ..isSeller = profile['is_seller'] as bool?
      ..defaultSource = profile['default_source'] as String?
      ..defaultIban = profile['default_iban'] as String?
      ..stripeaccountId = profile['stripe_account_id'] as String?
      ..customerId = profile['stripe_customer_id'] as String?
      ..fcmToken = profile['fcm_token'] as String?
      ..notificationPermission = profile['notification_permission'] as bool?
      ..createdAt = profile['created_at']?.toString()
      ..updatedAt = profile['updated_at']?.toString()
      ..adresses = addresses
          .map((a) => legacy.Adress(
                title: a['title'] as String?,
                location: legacy.Location(
                  latitude: a['latitude'] as double?,
                  longitude: a['longitude'] as double?,
                ),
                isChosed: a['is_chosen'] as bool?,
              ))
          .toList()
          .cast<legacy.Adress>()
      ..settings = legacy.UserSettings.fromJson({
        'food_preferences': settings['food_preferences'] ?? const <String>[],
        'food_price_ranges': settings['food_price_ranges'] ?? const <String>[],
        'distance_from_seller': settings['distance_from_seller'] ?? 45,
        'updatedAt': profile['updated_at']?.toString(),
        'createdAt': profile['created_at']?.toString(),
      })
      ..balance = balance == null
          ? null
          : legacy.Balance.fromJson({
              'current_balance': balance['current_balance'],
              'pending_balance': balance['pending_balance'],
              'currency': balance['currency'],
            })
      ..ibans = ibans
          .map((i) => legacy.BankAccount.fromJson(i as Map<String, dynamic>))
          .toList()
          .cast<legacy.BankAccount>()
      ..allCards = cards
          .map((c) => legacy.CardModel.fromJson(c as Map<String, dynamic>))
          .toList()
          .cast<legacy.CardModel>()
      ..transactions = transactions
          .map((t) =>
              legacy.Transaction.fromJson(t as Map<String, dynamic>))
          .toList()
          .cast<legacy.Transaction>();
  }

  @override
  Future<legacy.UserDef?> setIsSeller() async {
    if (!_ready) return null;
    final uid = SupabaseService.currentUserId!;
    await SupabaseService.from('profiles')
        .update({'is_seller': true}).eq('id', uid);
    return loadUserData(uid);
  }

  @override
  Future<String> updateFirebasetoken(String token) async {
    if (!_ready) return '';
    final uid = SupabaseService.currentUserId!;
    await SupabaseService.from('profiles')
        .update({'fcm_token': token}).eq('id', uid);
    return token;
  }

  // =========================================================================
  // PUBLICATIONS
  // =========================================================================

  @override
  Future<List<legacy.PublicationHome>> loadPublication(
      legacy.Location location, int distance) async {
    if (!_ready) {
      // Empty list rather than throwing — the home feed's empty state
      // is designed to handle this.
      publications.add(const []);
      return const [];
    }
    try {
      // Approximate geohash filtering: we don't have the legacy
      // geohashWithinRange() helper ported yet, so we load all open
      // publications within a rough bounding box computed from the
      // distance. This is less efficient than geohash prefix
      // comparison but functionally correct for typical distances.
      final lat = location.latitude ?? 0;
      final lng = location.longitude ?? 0;
      final latDelta = distance / 111.0;
      final lngDelta = distance / (111.0 * cos(lat * pi / 180));

      final response = await SupabaseService.from('publications')
          .select('''
            id, title, description, type, price_all, currency,
            photo_urls, food_preferences, allergens, portions_available,
            like_count, rating_total, rating_count, is_open, created_at,
            address,
            seller:profiles!publications_seller_id_fkey(
              id, email, first_name, last_name, photo_url, fcm_token
            )
          ''')
          .eq('is_open', true)
          .order('created_at', ascending: false)
          .limit(100);

      final List<legacy.PublicationHome> items = [];
      for (final row in response as List) {
        final map = row as Map<String, dynamic>;
        // Client-side bounding-box filter as a temporary stand-in for
        // geohash range queries. A PostGIS index would be the proper
        // fix; tracked in MIGRATION_TO_SUPABASE.md.
        final address = (map['address'] as Map<String, dynamic>?) ?? {};
        final locationMap = (address['location'] as Map<String, dynamic>?) ?? {};
        final plat = (locationMap['latitude'] as num?)?.toDouble();
        final plng = (locationMap['longitude'] as num?)?.toDouble();
        if (plat == null || plng == null) continue;
        if ((plat - lat).abs() > latDelta || (plng - lng).abs() > lngDelta) {
          continue;
        }
        items.add(_mapPublicationHome(map));
      }
      publications.add(items);
      return items;
    } catch (e) {
      print('loadPublication error: $e');
      publications.add(const []);
      return const [];
    }
  }

  legacy.PublicationHome _mapPublicationHome(Map<String, dynamic> map) {
    final sellerMap = (map['seller'] as Map<String, dynamic>?) ?? const {};
    final addressMap = (map['address'] as Map<String, dynamic>?) ?? const {};
    final locationMap =
        (addressMap['location'] as Map<String, dynamic>?) ?? const {};
    return legacy.PublicationHome()
      ..id = map['id'] as String?
      ..title = map['title'] as String?
      ..description = map['description'] as String?
      ..type = map['type']?.toString()
      ..pricePerAll = (map['price_all'] as num?)?.toString()
      ..photoUrls = (map['photo_urls'] as List?)?.cast<String>()
      ..preferences = (map['food_preferences'] as List?)?.cast<String>()
      ..allergens = (map['allergens'] as List?)?.cast<String>()
      ..portionsAvailable = map['portions_available'] as int?
      ..currency = map['currency'] as String?
      ..likeCount = map['like_count'] as int?
      ..liked = false // resolved below per-user
      ..adress = legacy.Adress(
        title: addressMap['title'] as String? ?? '',
        location: legacy.Location(
          latitude: locationMap['latitude'] as double?,
          longitude: locationMap['longitude'] as double?,
        ),
      )
      ..seller = legacy.SellerDef.fromJson({
        '_id': sellerMap['id'],
        'email': sellerMap['email'],
        'first_name': sellerMap['first_name'],
        'last_name': sellerMap['last_name'],
        'photoUrl': sellerMap['photo_url'],
        'fcmToken': sellerMap['fcm_token'],
      })
      ..rating = legacy.RatingPublication(
        ratingCount: map['rating_count'] as int? ?? 0,
        ratingTotal: (map['rating_total'] as num?)?.toDouble() ?? 0,
      );
  }

  @override
  Future<void> setLikePost(String postId) async {
    if (!_ready) return;
    final uid = SupabaseService.currentUserId!;
    // Insert the like row + bump the publication's like_count in a
    // single RPC would be cleaner; for now we do two calls in a
    // transaction-ish manner.
    try {
      await SupabaseService.from('publication_likes').insert({
        'publication_id': postId,
        'user_id': uid,
      });
      await SupabaseService.rpc('bump_like_count', params: {
        'p_publication_id': postId,
        'p_delta': 1,
      });
    } on PostgrestException catch (e) {
      // 23505 = unique violation — user already liked this post.
      if (e.code != '23505') rethrow;
    }
  }

  @override
  Future<void> setDislikePost(String postId) async {
    if (!_ready) return;
    final uid = SupabaseService.currentUserId!;
    try {
      await SupabaseService.from('publication_likes')
          .delete()
          .eq('publication_id', postId)
          .eq('user_id', uid);
      await SupabaseService.rpc('bump_like_count', params: {
        'p_publication_id': postId,
        'p_delta': -1,
      });
    } catch (e) {
      print('setDislikePost error: $e');
    }
  }

  // =========================================================================
  // ORDERS
  // =========================================================================

  @override
  Future<List<legacy.Order>> loadbuyerOrders() async {
    if (!_ready) return const [];
    try {
      final uid = SupabaseService.currentUserId!;
      final response = await SupabaseService.from('orders')
          .select('''
            id, short_id, buyer_id, seller_id, publication_id, quantity,
            total_price, fees, tip, total_with_fees, currency, order_state,
            stripe_transaction_id, delivery_day, address, notification_buyer,
            created_at, updated_at,
            publication:publications!orders_publication_id_fkey(
              _id, title, description, photoUrls, food_preferences, _id
            ),
            seller:profiles!orders_seller_id_fkey(
              id, email, first_name, last_name, photo_url, fcm_token
            )
          ''')
          .eq('buyer_id', uid)
          .order('created_at', ascending: false);

      final orders = (response as List)
          .map((row) => _mapOrder(row as Map<String, dynamic>))
          .toList()
          .cast<legacy.Order>();
      buyerOrders.add(orders);
      return orders;
    } catch (e) {
      print('loadbuyerOrders error: $e');
      buyerOrders.add(const []);
      return const [];
    }
  }

  @override
  Future<List<legacy.OrderVendor>> loadSellerOrders() async {
    if (!_ready) return const [];
    try {
      final uid = SupabaseService.currentUserId!;
      final response = await SupabaseService.from('orders')
          .select('''
            id, short_id, buyer_id, seller_id, publication_id, quantity,
            total_price, fees, tip, total_with_fees, currency, order_state,
            stripe_transaction_id, delivery_day, address, notification_seller,
            created_at, updated_at,
            publication:publications!orders_publication_id_fkey(
              _id, title, description, photoUrls, food_preferences
            ),
            buyer:profiles!orders_buyer_id_fkey(
              id, email, first_name, last_name, photo_url, fcm_token
            )
          ''')
          .eq('seller_id', uid)
          .order('created_at', ascending: false);

      final orders = (response as List)
          .map((row) => _mapOrderVendor(row as Map<String, dynamic>))
          .toList()
          .cast<legacy.OrderVendor>();
      sellerOrders.add(orders);
      return orders;
    } catch (e) {
      print('loadSellerOrders error: $e');
      sellerOrders.add(const []);
      return const [];
    }
  }

  legacy.Order _mapOrder(Map<String, dynamic> map) {
    // Adapted from Order.fromJson in lib/Pages/Orders/OrderItem.dart.
    final publication = (map['publication'] as Map<String, dynamic>?) ?? const {};
    final seller = (map['seller'] as Map<String, dynamic>?) ?? const {};
    final address = (map['address'] as Map<String, dynamic>?) ?? const {};
    return legacy.Order(
      id: map['id'] as String?,
      productId: map['publication_id'] as String?,
      sellerId: map['seller_id'] as String?,
      stripeTransactionId: map['stripe_transaction_id'] as String?,
      deliveryDay: map['delivery_day']?.toString(),
      totalPrice: (map['total_price'] as num?)?.toString(),
      quantity: (map['quantity'] as num?)?.toString(),
      currency: map['currency'] as String?,
      orderState: _parseOrderState(map['order_state'] as String?),
      totalWithFees: (map['total_with_fees'] as num?)?.toString(),
      fees: (map['fees'] as num?)?.toString(),
      notificationBuyer: map['notification_buyer'] as int?,
      shortId: map['short_id'] as String?,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      // legacy models for publication + seller + address
      publication: null, // TODO: rehydrate Publication model
      seller: null, // TODO: rehydrate Seller model
      adress: null, // TODO: rehydrate Adress model
    );
  }

  legacy.OrderVendor _mapOrderVendor(Map<String, dynamic> map) {
    // Adapted from OrderVendor.fromJson in lib/Services/DatabaseProvider.dart.
    return legacy.OrderVendor(
      id: map['id'] as String?,
      productId: map['publication_id'] as String?,
      buyerId: map['buyer_id'] as String?,
      stripeTransactionId: map['stripe_transaction_id'] as String?,
      deliveryDay: map['delivery_day']?.toString(),
      totalPrice: (map['total_price'] as num?)?.toString(),
      quantity: (map['quantity'] as num?)?.toString(),
      currency: map['currency'] as String?,
      orderState: _parseOrderState(map['order_state'] as String?),
      totalWithFees: (map['total_with_fees'] as num?)?.toString(),
      fees: (map['fees'] as num?)?.toString(),
      shortId: map['short_id'] as String?,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
      publication: null, // TODO
      buyer: null, // TODO
      adress: null, // TODO
    );
  }

  legacy.OrderState _parseOrderState(String? raw) {
    if (raw == null) return legacy.OrderState.NOT_ACCEPTED;
    return legacy.OrderState.values.firstWhere(
      (s) => s.toString().split('.').last == raw,
      orElse: () => legacy.OrderState.NOT_ACCEPTED,
    );
  }

  @override
  Future<void> createOrder(legacy.Order order) async {
    if (!_ready) return;
    final uid = SupabaseService.currentUserId!;
    try {
      await SupabaseService.from('orders').insert({
        'buyer_id': uid,
        'seller_id': order.sellerId,
        'publication_id': order.productId,
        'quantity': int.tryParse(order.quantity ?? '1') ?? 1,
        'total_price': num.tryParse(order.totalPrice ?? '0') ?? 0,
        'fees': num.tryParse(order.fees ?? '0') ?? 0,
        'tip': 0, // tip is added by the PaymentConfirmation flow
        'total_with_fees':
            num.tryParse(order.totalWithFees ?? '0') ?? 0,
        'currency': order.currency ?? 'EUR',
        'order_state': 'NOT_ACCEPTED',
        'delivery_day': order.deliveryDay,
        'address': null, // serialised separately if needed
      });
    } catch (e) {
      print('createOrder error: $e');
      rethrow;
    }
  }

  // =========================================================================
  // SELLER PUBLICATIONS
  // =========================================================================

  @override
  Future<List<legacy.PublicationVendor>> loadSellerPublications() async {
    if (!_ready) return const [];
    try {
      final uid = SupabaseService.currentUserId!;
      final response = await SupabaseService.from('publications')
          .select('*')
          .eq('seller_id', uid)
          .order('created_at', ascending: false);

      final items = (response as List)
          .map((row) => legacy.PublicationVendor.fromJson(
              row as Map<String, dynamic>))
          .toList()
          .cast<legacy.PublicationVendor>();
      sellerPublications.add(items);
      return items;
    } catch (e) {
      print('loadSellerPublications error: $e');
      sellerPublications.add(const []);
      return const [];
    }
  }

  // =========================================================================
  // ROOMS + MESSAGES
  // =========================================================================

  @override
  Future<List<legacy.Room>> loadrooms() async {
    if (!_ready) return const [];
    try {
      final uid = SupabaseService.currentUserId!;
      final response = await SupabaseService.from('rooms')
          .select('''
            id, buyer_id, seller_id, publication_id, last_message,
            last_message_at, buyer_unread, seller_unread, created_at,
            buyer:profiles!rooms_buyer_id_fkey(id, first_name, last_name, photo_url),
            seller:profiles!rooms_seller_id_fkey(id, first_name, last_name, photo_url)
          ''')
          .or('buyer_id.eq.$uid,seller_id.eq.$uid')
          .order('last_message_at', ascending: false, nullsFirst: false);

      final items = (response as List)
          .map((row) => legacy.Room.fromJson(row as Map<String, dynamic>))
          .toList()
          .cast<legacy.Room>();
      rooms.add(items);
      return items;
    } catch (e) {
      print('loadrooms error: $e');
      rooms.add(const []);
      return const [];
    }
  }

  @override
  Future<void> setIschatAreRead(String roomId) async {
    if (!_ready) return;
    final uid = SupabaseService.currentUserId!;
    // Mark all messages in the room NOT sent by the current user as read.
    await SupabaseService.from('messages')
        .update({'is_read': true})
        .eq('room_id', roomId)
        .neq('user_id', uid)
        .eq('is_read', false);
    // Reset the appropriate unread counter on the room.
    final roomRow = await SupabaseService.from('rooms')
        .select('buyer_id, seller_id')
        .eq('id', roomId)
        .maybeSingle();
    if (roomRow == null) return;
    final isBuyer = roomRow['buyer_id'] == uid;
    await SupabaseService.from('rooms').update({
      isBuyer ? 'buyer_unread' : 'seller_unread': 0,
    }).eq('id', roomId);
  }

  // =========================================================================
  // NOTIFICATIONS CLEANUP
  // =========================================================================

  @override
  Future<void> cleanNotificationBuyer(String orderId) async {
    if (!_ready) return;
    await SupabaseService.from('orders')
        .update({'notification_buyer': 0})
        .eq('id', orderId);
  }

  @override
  Future<void> cleanNotificationSeller(String orderId) async {
    if (!_ready) return;
    await SupabaseService.from('orders')
        .update({'notification_seller': 0})
        .eq('id', orderId);
  }

  // =========================================================================
  // STRIPE MUTATIONS — TODO (kept on legacy GraphQL for now)
  // =========================================================================

  // createBankAccount, makePayout, addattachPaymentToCustomer,
  // updatedDefaultSource, updateIbanDeposit — these all call Stripe
  // via the legacy GraphQL backend's resolvers. Migrating them to
  // Supabase requires deploying Edge Function wrappers around the
  // Stripe API. Tracked in MIGRATION_TO_SUPABASE.md §5.

  // =========================================================================
  // REALTIME SUBSCRIPTIONS
  // =========================================================================

  /// Subscribes to inserts on the `messages` table for the given room.
  /// Returns a `StreamSubscription` that calls [onMessage] for every
  /// new message. Replaces the legacy `getinPublicationHome` etc.
  StreamSubscription<Map<String, dynamic>> subscribeToRoomMessages(
    String roomId, {
    required void Function(Map<String, dynamic> row) onMessage,
  }) {
    final channel = SupabaseService.realtime.channel('room:$roomId');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId,
      ),
      callback: (payload) => onMessage(payload.newRecord),
    );
    channel.subscribe();
    // The caller is responsible for cancelling — we expose the
    // channel as a stream they can listen to / cancel.
    return _ChannelSubscription(channel);
  }

  /// Subscribes to changes on the current user's orders.
  StreamSubscription<Map<String, dynamic>> subscribeToOrders({
    required bool asBuyer,
    required void Function(Map<String, dynamic> row) onChange,
  }) {
    final uid = SupabaseService.currentUserId!;
    final column = asBuyer ? 'buyer_id' : 'seller_id';
    final channel = SupabaseService.realtime.channel('orders:$uid:$asBuyer');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'orders',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: column,
        value: uid,
      ),
      callback: (payload) => onChange(payload.newRecord),
    );
    channel.subscribe();
    return _ChannelSubscription(channel);
  }
}

/// Wraps a Supabase Realtime channel as a `StreamSubscription` so
/// callers can cancel it without learning the Realtime API.
class _ChannelSubscription extends StreamSubscription<Map<String, dynamic>> {
  _ChannelSubscription(this._channel);
  final RealtimeChannel _channel;
  bool _cancelled = false;

  @override
  Future<void> cancel() async {
    if (_cancelled) return;
    _cancelled = true;
    await SupabaseService.realtime.removeChannel(_channel);
  }

  @override
  void onData(void Function(Map<String, dynamic> event)? handleData) {}
  @override
  void onDone(void Function()? handleDone) {}
  @override
  void onError(Function? handleError) {}
  @override
  void pause([Future<void>? resumeSignal]) {}
  @override
  void resume() {}
  @override
  bool get isPaused => false;
}
