import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Onboarding/OnboardingModel.dart';
import 'package:kookers/UI/Colors.dart';

/// Renders a single onboarding slide.
///
/// The `OnboardingModel` now holds **translation keys** (e.g.
/// 'onboarding.step1_title') instead of literal copy, so this widget
/// resolves them via `.tr()` at paint time. That lets the same
/// `OnboardingPager` page list drive every supported locale.
class OnboardingPage extends StatelessWidget {
  final OnboardingModel? data;
  const OnboardingPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KookersColors.background,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const SizedBox(height: 40),
                  Center(
                    child: Image(
                      height: 340,
                      width: 310,
                      image: AssetImage(data?.placeHolder ?? ''),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
                    child: Text(
                      (data?.title ?? '').tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          fontSize: 36,
                          color: KookersColors.textPrimary,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
                    child: Text(
                      (data?.description ?? '').tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          fontSize: 17,
                          color: KookersColors.textSecondary,
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ),
            const Expanded(flex: 1, child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
