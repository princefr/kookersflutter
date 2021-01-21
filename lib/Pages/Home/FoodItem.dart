import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:provider/provider.dart';


class FoodItemShimmer extends StatelessWidget {
  const FoodItemShimmer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 210,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Stack(
                children: [
                    Container(decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                        height: 135,
                        width: MediaQuery.of(context).size.width,
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),padding: const EdgeInsets.all(10.0), child: Text("5 KM", style: GoogleFonts.montserrat(color: Colors.white))),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child:Align(
                      alignment: Alignment.topRight,
                      child: Container(child: Icon(CupertinoIcons.heart, size: 35, color: Colors.white,)),
                    )
                  ),

                ],
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),child: Text("Nougatine au lardon", style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 20))),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(children: [
                                    Icon(CupertinoIcons.star_fill, size: 13, color: Colors.yellow[900]),
                                    SizedBox(width: 5),
                                    Text("4.7")

                                  ],),
                                )
                              )
                        )
                      ),
                    ],
                  )
                ]
              ),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),child: Text("15 \$", style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 20)))
              ],)
            ],
          ),
        ),
      ),
    );
  }
}


class FoodItem extends StatefulWidget {
  final Function onTap;
  final PublicationHome publication;
  const FoodItem({Key key, this.onTap, @required this.publication}) : super(key: key);

  @override
  _FoodItemState createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem> with AutomaticKeepAliveClientMixin<FoodItem> {


   double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    var earthRadius = 6378137.0;
    var dLat = _toRadians(endLatitude - startLatitude);
    var dLon = _toRadians(endLongitude - startLongitude);

    var a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(_toRadians(startLatitude)) *
            cos(_toRadians(endLatitude));
    var c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  static _toRadians(double degree) {
    return degree * pi / 180;
  }

    @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);

    return InkWell(
          onTap: this.widget.onTap,
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 210,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Stack(
                children: [
                    Image(
                        height: 135,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(this.widget.publication.photoUrls[0]),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),padding: const EdgeInsets.all(10.0), child: Text((this.distanceBetween(this.widget.publication.adress.location.latitude, this.widget.publication.adress.location.longitude, databaseService.user.value.adresses.firstWhere((element) => element.isChosed).location.latitude, databaseService.user.value.adresses.firstWhere((element) => element.isChosed).location.longitude).floor() / 1000).round().toString() + " " + "km", style: GoogleFonts.montserrat(color: Colors.white))),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child:Align(
                      alignment: Alignment.topRight,
                      child: Icon(CupertinoIcons.heart, size: 35, color: Colors.white,),
                    )
                  ),

                ],
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(this.widget.publication.title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16),),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(children: [
                                    Icon(CupertinoIcons.star_fill, size: 13, color: Colors.yellow[900]),
                                    SizedBox(width: 5),
                                    Text("4.7")

                                  ],),
                                )
                              )
                        )
                      ),
                    ],
                  )
                ]
              ),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("15 \$", style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 20))
              ],)
            ],
          ),
        ),
      ),
    );
  }
}


