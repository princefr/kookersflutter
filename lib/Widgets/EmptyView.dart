import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Theme.dart';
import 'package:lottie/lottie.dart';

/// Empty state for the home feed.
///
/// The previous version showed a Lottie animation and the static
/// text "Vous n'avez aucun achat" — which made no sense on the home tab
/// (the home tab lists *publications*, not purchases). The widget is now
/// generic, with a configurable title / subtitle / optional CTA so each
/// screen can phrase the empty state in a way that actually helps the
/// user do the next thing.
///
/// [title] and [subtitle] accept **translation keys** (e.g.
/// 'empty.homeTitle') OR raw strings. If a key resolves to itself via
/// `.tr()`, that's fine — easy_localization returns the input verbatim
/// when no translation is found.
class EmptyView extends StatelessWidget {
  /// Translation key (or literal) for the headline.
  final String title;

  /// Translation key (or literal) for the supporting copy.
  final String subtitle;

  /// Optional CTA label (also a translation key or literal).
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  const EmptyView({
    super.key,
    this.title = 'empty.homeTitle',
    this.subtitle = 'empty.homeSubtitle',
    this.ctaLabel,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: KookersSpacing.xl, vertical: KookersSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/lf30_editor_dg6paekd.json',
              height: 160,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: KookersSpacing.lg),
            Text(
              title.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: KookersColors.textPrimary,
              ),
            ),
            const SizedBox(height: KookersSpacing.sm),
            Text(
              subtitle.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                height: 1.45,
                color: KookersColors.textSecondary,
              ),
            ),
            if (ctaLabel != null && onCtaTap != null) ...[
              const SizedBox(height: KookersSpacing.xl),
              ElevatedButton(
                onPressed: onCtaTap,
                child: Text(ctaLabel!.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Variant used by list-style empty states (messages, orders, ...).
class EmptyViewElse extends StatelessWidget {
  /// Translation key (or literal) for the message.
  final String text;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  const EmptyViewElse({
    super.key,
    required this.text,
    this.ctaLabel,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: KookersSpacing.xl, vertical: KookersSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: KookersColors.textSecondary,
              ),
            ),
            if (ctaLabel != null && onCtaTap != null) ...[
              const SizedBox(height: KookersSpacing.lg),
              ElevatedButton(
                onPressed: onCtaTap,
                child: Text(ctaLabel!.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
