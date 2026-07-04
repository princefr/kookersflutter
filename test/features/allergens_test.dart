// Tests for allergen tagging (FEATURE_PROPOSALS.md §1.3).
//
// Covers the Allergen enum, AllergenChips widget rendering, and
// PublicationHome.fromJson parsing of the new `allergens` field.

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/Models/Allergen.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/AllergenChips.dart';

void main() {
  // Provide a minimal EasyLocalization delegate so .tr() returns the
  // key verbatim instead of throwing.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
  });

  group('Allergen enum', () {
    test('has exactly 14 EU mandatory allergens', () {
      expect(Allergen.values.length, 14);
    });

    test('every allergen has a unique code', () {
      final codes = Allergen.values.map((a) => a.code).toSet();
      expect(codes.length, 14);
    });

    test('every allergen has a translation key under "allergens."', () {
      for (final a in Allergen.values) {
        expect(a.translationKey.startsWith('allergens.'), isTrue);
      }
    });

    test('fromCode round-trips through code for every value', () {
      for (final a in Allergen.values) {
        expect(Allergen.fromCode(a.code), a);
      }
    });

    test('fromCode returns null for unknown codes', () {
      expect(Allergen.fromCode(null), isNull);
      expect(Allergen.fromCode(''), isNull);
      expect(Allergen.fromCode('nonexistent'), isNull);
    });

    test('parseList silently skips unknown codes', () {
      final parsed = Allergen.parseList(
        ['gluten', 'milk', 'unknown', 'peanuts', null, ''],
      );
      expect(parsed, [Allergen.gluten, Allergen.milk, Allergen.peanuts]);
    });

    test('parseList handles null input', () {
      expect(Allergen.parseList(null), isEmpty);
    });
  });

  group('PublicationHome.allergens', () {
    test('fromJson parses the allergens field', () {
      final publication = PublicationHome.fromJson({
        '_id': 'p1',
        'title': 'Pizza',
        'description': '',
        'type': 'Plates',
        'price_all': '12',
        'photoUrls': ['https://example.com/p.jpg'],
        'adress': {
          'location': {'latitude': 48.8, 'longitude': 2.3}
        },
        'seller': {
          '_id': 's1',
          'email': 'chef@x.com',
          'first_name': 'Marie',
          'last_name': 'Curie',
          'fcmToken': 'tok',
          'photoUrl': '',
        },
        'food_preferences': ['Vegetarian'],
        'allergens': ['gluten', 'milk'],
        'portions_available': 3,
        'rating': {'rating_total': 4.5, 'rating_count': 10},
        'currency': 'EUR',
        'likeCount': 5,
        'likes': false,
      });

      expect(publication.allergens, ['gluten', 'milk']);
      expect(publication.portionsAvailable, 3);
    });

    test('fromJson defaults allergens to empty list when missing', () {
      final publication = PublicationHome.fromJson({
        '_id': 'p1',
        'title': 'Salad',
        'description': '',
        'type': 'Plates',
        'price_all': '8',
        'photoUrls': [],
        'adress': {
          'location': {'latitude': 0, 'longitude': 0}
        },
        'seller': {
          '_id': 's1',
          'email': '',
          'first_name': '',
          'last_name': '',
          'fcmToken': '',
          'photoUrl': '',
        },
        'food_preferences': [],
        'rating': {'rating_total': 0, 'rating_count': 0},
        'currency': 'EUR',
        'likeCount': 0,
        'likes': false,
      });

      expect(publication.allergens, isEmpty);
      expect(publication.portionsAvailable, isNull);
    });
  });

  group('AllergenChips widget', () {
    testWidgets('renders "No allergens" when list is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllergenChips(allergens: const []),
          ),
        ),
      );
      // Without EasyLocalization initialized, .tr() returns the key.
      expect(find.text('allergens.none'), findsOneWidget);
    });

    testWidgets('renders one chip per allergen when non-empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllergenChips(
              allergens: const [Allergen.gluten, Allergen.milk],
            ),
          ),
        ),
      );
      // Header label + 2 chip labels.
      expect(find.text('allergens.contains'), findsOneWidget);
      expect(find.text('allergens.gluten'), findsOneWidget);
      expect(find.text('allergens.milk'), findsOneWidget);
    });

    testWidgets('renders "No allergens" when allergens is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AllergenChips(allergens: null)),
        ),
      );
      expect(find.text('allergens.none'), findsOneWidget);
    });
  });
}
