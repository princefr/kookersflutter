import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Messages/FullScreenImage.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/InfoDialog.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class VendorPubPage extends StatefulWidget {
  final PublicationVendor publication;
  VendorPubPage({Key key, this.publication}) : super(key: key);

  @override
  _VendorPubPageState createState() => _VendorPubPageState();
}

class _VendorPubPageState extends State<VendorPubPage> {
  Future<bool> cLosePublication(
      GraphQLClient client, String publicationId, bool isClosed) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
          mutation updatePublication($publication_id: String, $is_closed: Boolean) {
                closePublication(publication_id: $publication_id, is_closed: $is_closed){
                    is_open
                }
            }
        """), variables: <String, dynamic>{
      "publication_id": publicationId,
      "is_closed": isClosed
    });

    return client
        .mutate(_options)
        .then((value) => value.data["closePublication"]["is_open"]);
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
      this.publicationSubscription = databaseService.getinPublicationSeller(
          this.widget.publication.id, this.publication);
    });
    super.initState();
  }

  StreamSubscription<PublicationVendor> publicationSubscription;
  // ignore: close_sinks
  BehaviorSubject<PublicationVendor> publication =
      new BehaviorSubject<PublicationVendor>();

  String successText = "";

  double calculateRating(total, count) {
    if ((total / count).isNaN) return 0;
    return (total / count);
  }

  @override
  void dispose() {
    this.publication.close();
    this.publicationSubscription.cancel();
    super.dispose();
  }

  StreamButtonController _streamButtonController = StreamButtonController();

  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);

    return Scaffold(
      appBar: TopBarWitBackNav(
          title: this.widget.publication.title,
          rightIcon: CupertinoIcons.chat_bubble,
          isRightIcon: false,
          height: 54,
          onTapRight: () {}),
      body: Container(
        child: ListView(children: [
          CarouselSlider(
              items: this.widget.publication.photoUrls.map((e) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => FullScreenImage(url: e)));
                  },
                  child: Hero(
                    tag: e,
                    child: Image(
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(e),
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 300.0,
                aspectRatio: 16 / 9,
                enlargeCenterPage: true,
                initialPage: 0,
                enableInfiniteScroll: false,
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(this.widget.publication.pricePerAll,
                    style: GoogleFonts.montserrat(
                        fontSize: 26, color: Colors.grey)),
              ),
              Row(children: [
                Text(""),
                SizedBox(width: 20),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.star_fill,
                          size: 13, color: Colors.yellow[900]),
                      SizedBox(width: 5),
                      Text(calculateRating(
                                  this.widget.publication.rating.ratingTotal,
                                  this.widget.publication.rating.ratingCount)
                              .toString() +
                          " " +
                          "(" +
                          this
                              .widget
                              .publication
                              .rating
                              .ratingCount
                              .toString() +
                          ")")
                    ],
                  ),
                ),
                SizedBox(width: 15),
              ])
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(this.widget.publication.description),
          ),
          Container(
            height: 40,
            child: Builder(builder: (BuildContext ctx) {
              if (this
                  .widget
                  .publication
                  .preferences
                  .length > 0) {
                return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: this
                        .widget
                        .publication
                        .preferences
                        .length,
                    itemBuilder: (ctx, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 5, right: 5, top: 3),
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0))),
                            padding: EdgeInsets.all(10),
                            child: Text(this
                                .widget
                                .publication
                                .preferences[index])),
                      );
                    });
              } else {
                return Container(
                  height: 40,
                  child: Text("Sans préférences"),
                  decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                );
              }
            }),
          ),
          Divider(),
          ListTile(
            leading: Icon(CupertinoIcons.home),
            title: Text(this.widget.publication.adress.title,
                style: GoogleFonts.montserrat()),
          ),
          ListTile(
            leading: Icon(CupertinoIcons.time),
            title: Text(this.widget.publication.createdAt,
                style: GoogleFonts.montserrat()),
          ),
          ListTile(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => InfoDialog(
                      infoText:
                          "Ce chiffre représente le montant que vous recevrez pour chacun(e) des portions ou plats que vous vendriez à l'aide la plateforme kookers une fois les frais de fonctionnement déduits."));
            },
            leading: Icon(CupertinoIcons.info_circle),
            title: Text("Ce que vous recevrez par plat",
                style: GoogleFonts.montserrat()),
          ),
          SizedBox(height: 40),
          StreamBuilder<PublicationVendor>(
              stream: this.publication.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return LinearProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                if (snapshot.hasError) return Text("i've a bad felling");
                if (snapshot.data == null) return Text("its empty out there");
                return StreamButton(
                    buttonColor:
                        snapshot.data.isOpen ? Colors.red : Colors.green,
                    buttonText: snapshot.data.isOpen
                        ? "Fermer la vente"
                        : "Ouvrir la vente",
                    errorText: "Une erreur s'est produite, reesayer",
                    loadingText: snapshot.data.isOpen
                        ? "Fermeture en cours"
                        : "Ouverture en cours",
                    successText: "effectuée",
                    controller: _streamButtonController,
                    onClick: () async {
                      _streamButtonController.isLoading();
                      this
                          .cLosePublication(
                              databaseService.client,
                              this.widget.publication.id,
                              !this.widget.publication.isOpen)
                          .then((value) {
                        //this.widget.publication.isOpen = value;
                        databaseService.loadSellerPublications();
                        _streamButtonController.isSuccess();
                      }).catchError((err) {
                        _streamButtonController.isError();
                      });
                    });
              }),
        ]),
      ),
    );
  }
}
