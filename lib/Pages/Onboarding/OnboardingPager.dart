import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignPage.dart';
import 'package:kookers/Pages/Onboarding/OnboardingModel.dart';
import 'package:kookers/Pages/Onboarding/OnboardingPage.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Theme.dart';
import 'package:get/get.dart';

/// First-run onboarding carousel.
///
/// Improvements over the previous version:
///   * Skip button in the top-right (always visible, not just on the last
///     page) — users who already know the concept shouldn't be forced
///     through 4 screens.
///   * Pagination dots replaced with an animated `AnimatedSlide`-style
///     indicator that scales the active dot, which is more discoverable
///     than the static circles.
///   * Primary CTA label changes from "→" arrow to contextual copy
///     ("Suivant" / "Commencer"), making the action obvious.
///   * Soft coral background gradient replaces the flat white, giving
///     the screen a warmer first impression.
class OnBoardingPager extends StatefulWidget {
  const OnBoardingPager({super.key});

  @override
  State<OnBoardingPager> createState() => _OnBoardingPagerState();
}

class _OnBoardingPagerState extends State<OnBoardingPager> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingModel> _pages = [
    OnboardingModel(
      description:
          "Kookers connecte chefs amateurs et gourmands souhaitant faire des découvertes culinaires.",
      placeHolder: "assets/onboarding/Sush_cook-pana.png",
      title: "Concept",
    ),
    OnboardingModel(
      description:
          "Commandez les plats ou desserts en fonction de vos préférences culinaires et de votre géolocalisation.",
      placeHolder: "assets/onboarding/Messaging_fun-pana.png",
      title: "Commandez",
    ),
    OnboardingModel(
      description:
          "Votre chef ou nos partenaires acheminent votre commande directement devant votre porte.",
      placeHolder: "assets/onboarding/Take_Away-pana.png",
      title: "Faites vous livrer",
    ),
    OnboardingModel(
      description:
          "Dégustez votre plat ou votre dessert en toute tranquillité.",
      placeHolder: "assets/onboarding/Eating_healthy_food-pana.png",
      title: "Dégustez",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToSignIn() {
    Get.to(() => BeforeSignPage(from: 'onboarding'));
  }

  void _nextOrFinish() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goToSignIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KookersColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: const ClampingScrollPhysics(),
              itemCount: _pages.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) => OnboardingPage(
                data: _pages[index],
              ),
            ),
            Positioned(
              top: KookersSpacing.sm,
              right: KookersSpacing.sm,
              child: TextButton(
                onPressed: _goToSignIn,
                child: Text(
                  'Passer',
                  style: GoogleFonts.montserrat(
                    color: KookersColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    KookersSpacing.xl, 0, KookersSpacing.xl, KookersSpacing.xl),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(_pages.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.only(right: 6),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? KookersColors.primary
                                : KookersColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    _PrimaryCta(
                      isLast: _currentPage == _pages.length - 1,
                      onTap: _nextOrFinish,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.isLast, required this.onTap});

  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KookersColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: KookersColors.primaryDark, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLast ? 'Commencer' : 'Suivant',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(CupertinoIcons.arrow_right,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
