import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignPage.dart';
import 'package:kookers/Models/Location.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/Shared/DistanceWidget.dart';
import 'package:kookers/Widgets/Shared/PriceDisplay.dart';
import 'package:kookers/Widgets/Shared/RatingWidget.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

// Using the shared FoodItemShimmer from ShimmerCard.dart

class FoodItem extends StatefulWidget {
  final Function? onTap;
  final PublicationHome publication;
  const FoodItem({Key? key, this.onTap, required this.publication})
      : super(key: key);

  @override
  _FoodItemState createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem>
    with AutomaticKeepAliveClientMixin<FoodItem> {
  
  Location _getUserLocation(DatabaseProviderService databaseService) {
    if (databaseService.user.value == null) {
      return databaseService.adress.value.location ?? Location();
    }
    return databaseService.user.value.adresses
        .firstWhere((element) => element.isChosed == true)
        .location ?? Location();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);

    return InkWell(
      onTap: this.widget.onTap as GestureTapCallback?,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 260,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Stack(
                children: [
                  Hero(
                    tag: this.widget.publication.photoUrls?[0] ?? '',
                    child: Image(
                      height: 135,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(
                          this.widget.publication.photoUrls?[0] ?? ''),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: DistanceWidget(
                        startLocation: this.widget.publication.adress?.location ?? Location(),
                        endLocation: _getUserLocation(databaseService),
                      ),
                    ),
                  ),
                  
                  Container(
                    child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Builder(
                            builder: (ctx) {
                              if (this.widget.publication.liked ?? false) {
                                return InkWell(
                                  onTap: (){
                                    if (databaseService.user.value == null) {
                                        showCupertinoModalBottomSheet(
                                            expand: false,
                                            context: context,
                                            builder: (context) => BeforeSignPage(from: "food_item",));
                                      }else{
                                        databaseService.updateLikeInPublication(
                                            this.widget.publication.id ?? '', false);
                                        databaseService
                                            .setDislikePost(this.widget.publication.id ?? '');
                                        setState(() {
                                          this.widget.publication.liked = false;
                                        });
                                      }
                                  },
                                    child: Icon(
                                    CupertinoIcons.heart_fill,
                                    size: 35,
                                    color: Colors.red,
                                  ),
                                );
                              } else {
                                return InkWell(
                                  onTap: (){
                                    if (databaseService.user.value == null) {
                                        showCupertinoModalBottomSheet(
                                            expand: false,
                                            context: context,
                                            builder: (context) => BeforeSignPage(from: "food_item"));
                                    }else{
                                        databaseService.updateLikeInPublication(
                                              this.widget.publication.id ?? '', true);
                                          databaseService
                                              .setLikePost(this.widget.publication.id ?? '');
                                          setState(() {
                                            this.widget.publication.liked = true;
                                          });
                                    }
                                  },
                                                                    child: Icon(
                                    CupertinoIcons.heart,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                );
                              }
                            },
                          ),
                        )),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  this.widget.publication.title ?? '',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: RatingWidget(
                          rating: this.widget.publication.getRating(),
                          ratingCount: this.widget.publication.rating?.ratingCount ?? 0,
                        ),
                      ),
                    ),
                  ],
                )
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriceDisplay(
                    price: this.widget.publication.pricePerAll ?? '',
                    currency: this.widget.publication.currency ?? 'EUR',
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 40,
                child: Builder(builder: (BuildContext ctx) {
                  if (this.widget.publication.preferences?.length != null && this.widget.publication.preferences!.length > 0) {
                    return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: this.widget.publication.preferences?.length ?? 0,
                        itemBuilder: (ctx, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, top: 3),
                            child: Chip(
                                backgroundColor: Colors.green[100],
                                label: Text(this
                                    .widget
                                    .publication
                                    .preferences?[index] ?? '')));
                        });
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                              label: Text("Sans préférences"),
                              backgroundColor: Colors.green[100])),
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
