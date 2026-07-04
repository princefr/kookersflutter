import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Models/Allergen.dart';
import 'package:kookers/UI/Colors.dart';

/// Compact row of red allergen chips, displayed on the food card and
/// the dish detail page.
///
/// Renders "Aucun allergène" if the publication declares none, so the
/// absence is itself a positive trust signal — buyers don't have to
/// wonder whether the seller simply forgot to fill the field.
class AllergenChips extends StatelessWidget {
  final List<Allergen>? allergens;
  final bool compact;

  const AllergenChips({
    super.key,
    required this.allergens,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = allergens ?? const <Allergen>[];
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                size: 14, color: KookersColors.success),
            const SizedBox(width: 4),
            Text(
              'allergens.none'.tr(),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: KookersColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'allergens.contains'.tr(),
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: KookersColors.danger,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: items.map((a) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: KookersColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: KookersColors.danger.withOpacity(0.4),
                      width: 0.5),
                ),
                child: Text(
                  a.translationKey.tr(),
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: KookersColors.danger,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
