import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Haptics.dart';

/// Sort order for the home feed.
///
/// The backend query (`loadPublication`) returns publications in
/// creation order (newest first, since they're reversed). The sort
/// dropdown applies a client-side re-sort on top of that, so it works
/// without backend changes — at the cost of needing all publications
/// loaded. For the typical feed size (<100 items in a city) that's
/// fine.
enum PublicationSort {
  newest,
  trending,
  topRated,
  priceAsc,
  priceDesc;

  String get labelKey => switch (this) {
        PublicationSort.newest => 'sort.newest',
        PublicationSort.trending => 'sort.trending',
        PublicationSort.topRated => 'sort.topRated',
        PublicationSort.priceAsc => 'sort.priceAsc',
        PublicationSort.priceDesc => 'sort.priceDesc',
      };
}

/// Compact sort dropdown shown in the home top bar.
///
/// Renders as a tappable chip with the current sort's label and a
/// chevron; tapping opens a popup menu with all five options.
class SortDropdown extends StatelessWidget {
  final PublicationSort current;
  final ValueChanged<PublicationSort> onChanged;
  const SortDropdown({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PublicationSort>(
      onSelected: (value) {
        Haptics.selection();
        onChanged(value);
      },
      itemBuilder: (context) => [
        for (final sort in PublicationSort.values)
          PopupMenuItem<PublicationSort>(
            value: sort,
            child: Row(
              children: [
                if (sort == current)
                  const Icon(Icons.check,
                      size: 16, color: KookersColors.primary)
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(sort.labelKey.tr()),
              ],
            ),
          ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: KookersColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: 14, color: KookersColors.primaryDark),
            const SizedBox(width: 4),
            Text(
              current.labelKey.tr(),
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: KookersColors.primaryDark,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 14, color: KookersColors.primaryDark),
          ],
        ),
      ),
    );
  }
}
