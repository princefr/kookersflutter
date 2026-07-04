import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignPage.dart';
import 'package:kookers/Models/Location.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/Widgets/Shared/DistanceWidget.dart';
import 'package:kookers/Widgets/Shared/PriceDisplay.dart';
import 'package:kookers/Widgets/Shared/RatingWidget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

/// Card used in the home feed.
///
/// Fixes the inverted auth-gate on the like button: signed-in users can
/// now actually like / unlike. Also re-styles the card so the photo,
/// distance chip, and like button read as a single coherent surface
/// instead of three loosely stacked widgets.
class FoodItem extends StatefulWidget {
  final Function? onTap;
  final PublicationHome publication;

  const FoodItem({super.key, this.onTap, required this.publication});

  @override
  State<FoodItem> createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem>
    with AutomaticKeepAliveClientMixin<FoodItem> {
  Location _getUserLocation(DatabaseProviderService databaseService) {
    // If the user is logged in we prefer the explicitly-chosen delivery
    // address; otherwise fall back to whatever the guest picker stored.
    if (databaseService.user.value.id != null) {
      return databaseService.adress.value.location ?? Location();
    }
    return databaseService.user.value.adresses
            ?.firstWhere((element) => element.isChosed == true,
                orElse: () => Adress())
            .location ??
        Location();
  }

  void _toggleLike(DatabaseProviderService databaseService) {
    // Auth gate — was previously inverted (`id != null` → signup),
    // which meant signed-in users could never like a post.
    if (databaseService.user.value.id == null) {
      showCupertinoModalBottomSheet(
        expand: false,
        context: context,
        builder: (context) => BeforeSignPage(from: 'food_item'),
      );
      return;
    }
    final wasLiked = widget.publication.liked ?? false;
    setState(() => widget.publication.liked = !wasLiked);
    databaseService.updateLikeInPublication(
        widget.publication.id ?? '', !wasLiked);
    if (wasLiked) {
      databaseService.setDislikePost(widget.publication.id ?? '');
    } else {
      databaseService.setLikePost(widget.publication.id ?? '');
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
    final publication = widget.publication;

    return InkWell(
      onTap: widget.onTap as GestureTapCallback?,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: KookersSpacing.lg, vertical: KookersSpacing.sm),
        child: Container(
          decoration: BoxDecoration(
            color: KookersColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: KookersColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo + distance chip + like button
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15.5)),
                child: Stack(
                  children: [
                    Hero(
                      tag: publication.photoUrls?[0] ?? '',
                      child: Image(
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            publication.photoUrls?[0] ?? ''),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: DistanceWidget(
                        startLocation:
                            publication.adress?.location ?? Location(),
                        endLocation: _getUserLocation(databaseService),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.black.withOpacity(0.35),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _toggleLike(databaseService),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              (publication.liked ?? false)
                                  ? CupertinoIcons.heart_fill
                                  : CupertinoIcons.heart,
                              size: 22,
                              color: (publication.liked ?? false)
                                  ? KookersColors.badge
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            publication.title ?? '',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: KookersColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: KookersSpacing.sm),
                        RatingWidget(
                          rating: publication.getRating(),
                          ratingCount: publication.rating?.ratingCount ?? 0,
                        ),
                      ],
                    ),
                    const SizedBox(height: KookersSpacing.xs),
                    PriceDisplay(
                      price: publication.pricePerAll ?? '',
                      currency: publication.currency ?? 'EUR',
                    ),
                    const SizedBox(height: KookersSpacing.md),
                    SizedBox(
                      height: 28,
                      child: _PreferencesRow(
                          preferences: publication.preferences),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferencesRow extends StatelessWidget {
  final List<String>? preferences;
  const _PreferencesRow({this.preferences});

  @override
  Widget build(BuildContext context) {
    final items = preferences ?? const <String>[];
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'food.noPreferences'.tr(),
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: KookersColors.textMuted,
          ),
        ),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: KookersSpacing.xs),
      itemBuilder: (context, index) => Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        label: Text(items[index]),
      ),
    );
  }
}
