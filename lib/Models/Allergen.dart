/// The 14 mandatory allergens that EU food businesses must declare
/// (Regulation (EU) No 1169/2011, Annex II).
///
/// Each enum value carries a translation key under `allergens.*` so the
/// UI can render the localized name via `.tr()`. The string value is
/// what gets stored in Firestore / GraphQL — a stable English code
/// that doesn't depend on the user's locale.
library;

enum Allergen {
  gluten('allergens.gluten'),
  crustaceans('allergens.crustaceans'),
  eggs('allergens.eggs'),
  fish('allergens.fish'),
  peanuts('allergens.peanuts'),
  soy('allergens.soy'),
  milk('allergens.milk'),
  nuts('allergens.nuts'),
  celery('allergens.celery'),
  mustard('allergens.mustard'),
  sesame('allergens.sesame'),
  sulphites('allergens.sulphites'),
  lupin('allergens.lupin'),
  molluscs('allergens.molluscs');

  const Allergen(this.translationKey);
  final String translationKey;

  /// Stable English code persisted to the database.
  String get code => name;

  /// Looks up an [Allergen] by its stable code; returns null if not
  /// found (e.g. the backend added a new allergen the app doesn't
  /// know yet — better to silently skip than to crash).
  static Allergen? fromCode(String? code) {
    if (code == null) return null;
    for (final a in Allergen.values) {
      if (a.code == code) return a;
    }
    return null;
  }

  /// Parses a raw list of allergen codes (e.g. from JSON) into a list
  /// of known [Allergen]s, silently skipping any unknown codes.
  static List<Allergen> parseList(List<dynamic>? raw) {
    if (raw == null) return const [];
    return raw
        .map((code) => fromCode(code?.toString()))
        .whereType<Allergen>()
        .toList(growable: false);
  }
}
