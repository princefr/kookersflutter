import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Haptics.dart';

/// Horizontal scrollable row of tappable quick-reply chips, shown
/// above the chat message input.
///
/// Tapping a chip fills the input field with the canned message
/// (without sending — the user can edit before pressing send).
class QuickReplies extends StatelessWidget {
  final ValueChanged<String> onPick;
  const QuickReplies({super.key, required this.onPick});

  /// Translation keys for the canned messages. Picked to cover the
  /// most common buyer↔seller exchanges without being spammy.
  static const _keys = <String>[
    'chat.quick.hello',
    'chat.quick.askTime',
    'chat.quick.askAvailability',
    'chat.quick.thanks',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _keys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final text = _keys[index].tr();
          return ActionChip(
            onPressed: () {
              Haptics.selection();
              onPick(text);
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
            backgroundColor: KookersColors.primarySoft,
            label: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: KookersColors.primaryDark,
              ),
            ),
          );
        },
      ),
    );
  }
}
