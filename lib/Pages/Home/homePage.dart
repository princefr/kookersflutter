import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Models/Location.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignAdress.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignPage.dart';
import 'package:kookers/Pages/Home/FoodIemChild.dart' show FoodItemChild;
import 'package:kookers/Pages/Home/FoodItem.dart';
import 'package:kookers/Pages/Home/Guidelines.dart';
import 'package:kookers/Pages/Home/HomePublish.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Pages/Home/HomeSettings.dart';
import 'package:kookers/Services/AnalyticsService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/ErrorBarService.dart';
import 'package:kookers/Services/PublicationProvider.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Theme.dart';
import 'package:kookers/Widgets/EmptyView.dart';
import 'package:kookers/Widgets/SortDropdown.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/subjects.dart';
import 'package:shimmer/shimmer.dart';

/// Top app bar of the home feed.
///
/// Shows the Kookers wordmark, the user's current delivery address
/// (tappable to open the address picker), and a settings/filter button.
class HomeTopBar extends StatelessWidget {
  final double height;
  final BehaviorSubject<int> percentage;
  final User user;

  const HomeTopBar({
    super.key,
    required this.percentage,
    required this.user,
    this.height = 121,
  });

  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: KookersColors.surface,
        border: Border(
          bottom: BorderSide(color: KookersColors.border, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: KookersSpacing.screenH, vertical: KookersSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Upload progress bar — only visible while a publication is being
            // pushed to the server.
            StreamBuilder<int>(
              stream: percentage,
              builder: (context, snapshot) {
                final value = snapshot.data ?? 0;
                if (value == 0) return const SizedBox(height: 0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value == 100 ? 1 : null,
                      backgroundColor: KookersColors.surfaceAlt,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          KookersColors.primary),
                      minHeight: 3,
                    ),
                  ),
                );
              },
            ),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/logo/logo_white.svg',
                  height: 28,
                  width: 28,
                  colorFilter: const ColorFilter.mode(
                      KookersColors.primary, BlendMode.srcIn),
                ),
                const SizedBox(width: 10),
                Text('Kookers',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: KookersColors.textPrimary,
                    )),
                const Spacer(),
                _SettingsButton(user: user, databaseService: databaseService),
              ],
            ),
            const SizedBox(height: KookersSpacing.sm),
            _AddressButton(user: user, databaseService: databaseService),
          ],
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.user, required this.databaseService});

  final User user;
  final DatabaseProviderService databaseService;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = databaseService.user.value.id != null;
    return Material(
      color: KookersColors.surfaceAlt,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (!isLoggedIn) {
            showCupertinoModalBottomSheet(
              expand: true,
              context: context,
              builder: (context) => BeforeSignPage(from: 'home'),
            );
            return;
          }
          showCupertinoModalBottomSheet(
            expand: false,
            context: context,
            builder: (context) => HomeSettings(user: user),
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(CupertinoIcons.slider_horizontal_3,
              size: 20, color: KookersColors.textPrimary),
        ),
      ),
    );
  }
}

class _AddressButton extends StatelessWidget {
  const _AddressButton({required this.user, required this.databaseService});

  final User user;
  final DatabaseProviderService databaseService;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = databaseService.user.value.id != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (!isLoggedIn) {
            showCupertinoModalBottomSheet(
              expand: true,
              context: context,
              builder: (context) => const BeforeAdress(isReturn: true),
            );
            return;
          }
          showCupertinoModalBottomSheet(
            expand: true,
            context: context,
            builder: (context) =>
                HomeSearchPage(isReturn: false, user: user),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: KookersSpacing.sm, vertical: KookersSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.location_solid,
                  size: 18, color: KookersColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: StreamBuilder<UserDef>(
                  stream: databaseService.user$,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 22,
                        width: 160,
                        child: Shimmer.fromColors(
                          baseColor: KookersColors.surfaceAlt,
                          highlightColor: KookersColors.border,
                          child: Container(
                            decoration: BoxDecoration(
                              color: KookersColors.surface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      );
                    }
                    final userDef = snapshot.data;
                    String? title;
                    if (userDef == null) {
                      title = databaseService.adress.value.title;
                    } else if (userDef.adresses?.isNotEmpty ?? false) {
                      title = userDef.adresses!
                          .firstWhere(
                            (element) => element.isChosed == true,
                            orElse: () => userDef.adresses!.first,
                          )
                          .title;
                    }
                    return Text(
                      title ?? 'home.chooseAddress'.tr(),
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: KookersColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              const Icon(CupertinoIcons.chevron_down,
                  size: 16, color: KookersColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final BehaviorSubject<int> _uploadPercentage =
      BehaviorSubject<int>.seeded(0);

  /// Current sort selection (defaults to newest). Persisted only
  /// in-memory — could be wired to SharedPreferences later.
  PublicationSort _sort = PublicationSort.newest;

  /// Returns the publications list sorted by the user's current
  /// [_sort] selection. All comparisons are null-safe.
  List<PublicationHome> _sorted(List<PublicationHome> items) {
    final copy = List<PublicationHome>.from(items);
    switch (_sort) {
      case PublicationSort.newest:
        return copy; // backend already returns newest first
      case PublicationSort.trending:
        copy.sort((a, b) =>
            (b.likeCount ?? 0).compareTo(a.likeCount ?? 0));
        return copy;
      case PublicationSort.topRated:
        copy.sort((a, b) => b.getRating().compareTo(a.getRating()));
        return copy;
      case PublicationSort.priceAsc:
        copy.sort((a, b) {
          final pa = num.tryParse(a.pricePerAll ?? '') ?? 0;
          final pb = num.tryParse(b.pricePerAll ?? '') ?? 0;
          return pa.compareTo(pb);
        });
        return copy;
      case PublicationSort.priceDesc:
        copy.sort((a, b) {
          final pa = num.tryParse(a.pricePerAll ?? '') ?? 0;
          final pb = num.tryParse(b.pricePerAll ?? '') ?? 0;
          return pb.compareTo(pa);
        });
        return copy;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPublications());
  }

  void _loadPublications() {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
    final userDef = databaseService.user.value;
    final Location? location = userDef.id != null
        ? databaseService.adress.value.location
        : userDef.adresses
            ?.firstWhere((element) => element.isChosed == true,
                orElse: () => Adress())
            .location;
    final distance = userDef.settings?.distanceFromSeller ?? 45;
    if (location != null) {
      databaseService.loadPublication(location, distance);
    }
  }

  Future<void> _onRefresh() async {
    _loadPublications();
    await Future.delayed(const Duration(milliseconds: 600));
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _uploadPercentage.close();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _openPublishFlow() async {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);

    // Auth check — was previously inverted (`id != null` → signup),
    // which made the FAB unusable for signed-in users.
    if (databaseService.user.value.id == null) {
      showCupertinoModalBottomSheet(
        expand: false,
        context: context,
        builder: (context) => BeforeSignPage(from: 'home'),
      );
      return;
    }

    if (databaseService.user.value.isSeller != true) {
      showCupertinoModalBottomSheet(
        expand: true,
        context: context,
        builder: (context) => GuidelinesToSell(),
      );
      return;
    }

    final publication = await showCupertinoModalBottomSheet<Publication>(
      expand: true,
      context: context,
      builder: (context) => HomePublish(user: widget.user),
    );
    if (publication == null || !mounted) return;

    _tryUpload(publication, isRetry: false);
  }

  void _tryUpload(Publication publication, {required bool isRetry}) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
    publication.uploadToServer(_uploadPercentage).then((_) async {
      _uploadPercentage.add(100);
      NotificationPanelService.showSuccess(context, 'home.publishSuccess'.tr());
      KookersEvents.publishSuccess(publicationId: publication.id ?? '');
      _uploadPercentage.add(0);
    }).catchError((_) {
      NotificationPanelService.showError(
        context,
        isRetry
            ? 'home.publishError'.tr()
            : 'home.publishRetry'.tr(),
      );
      _uploadPercentage.add(0);
      if (!isRetry) {
        Future.delayed(const Duration(seconds: 10), () {
          if (!mounted) return;
          _tryUpload(publication, isRetry: true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);

    return Scaffold(
      backgroundColor: KookersColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(121),
        child: HomeTopBar(
          user: widget.user,
          percentage: _uploadPercentage,
        ),
      ),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<PublicationHome>>(
          stream: databaseService.publications$,
          initialData: databaseService.publications.value,
          builder: (context, snapshot) {
            final items = _sorted(snapshot.data ?? const []);
            final isLoading = snapshot.connectionState ==
                    ConnectionState.waiting &&
                items.isEmpty;

            if (isLoading) return const _HomeFeedShimmer();

            if (items.isEmpty) {
              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                onRefresh: _onRefresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: KookersSpacing.xxl),
                    EmptyView(),
                  ],
                ),
              );
            }

            return SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              onRefresh: _onRefresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                    bottom: KookersSpacing.xxl, top: KookersSpacing.sm),
                itemCount: items.length + 1,
                separatorBuilder: (context, index) {
                  if (index == 0) return const SizedBox.shrink();
                  return const SizedBox(height: KookersSpacing.sm);
                },
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Sort dropdown row — sticky at the top of the feed.
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: KookersSpacing.lg,
                          vertical: KookersSpacing.xs),
                      child: Row(
                        children: [
                          Text(
                            '${items.length} ${items.length == 1 ? 'home.oneDish' : 'home.manyDishes'.tr()}',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: KookersColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          SortDropdown(
                            current: _sort,
                            onChanged: (sort) =>
                                setState(() => _sort = sort),
                          ),
                        ],
                      ),
                    );
                  }
                  final publication = items[index - 1];
                  return FoodItem(
                    publication: publication,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => FoodItemChild(
                            publication: publication,
                            user: widget.user,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('publish_button'),
        onPressed: _openPublishFlow,
        tooltip: 'home.publishTooltip'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _HomeFeedShimmer extends StatelessWidget {
  const _HomeFeedShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: KookersColors.surfaceAlt,
      highlightColor: KookersColors.border,
      child: ListView.builder(
        padding: const EdgeInsets.all(KookersSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: KookersSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: KookersColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: KookersSpacing.md),
              Container(
                height: 16,
                width: 180,
                decoration: BoxDecoration(
                  color: KookersColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: KookersSpacing.sm),
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                  color: KookersColors.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
