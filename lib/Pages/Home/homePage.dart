import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignAdress.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignPage.dart';
import 'package:kookers/Pages/Home/FoodIemChild.dart';
import 'package:kookers/Pages/Home/FoodItem.dart';
import 'package:kookers/Pages/Home/Guidelines.dart';
import 'package:kookers/Pages/Home/HomePublish.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Pages/Home/HomeSettings.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/ErrorBarService.dart';
import 'package:kookers/Services/PublicationProvider.dart';
import 'package:kookers/Widgets/EmptyView.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/subjects.dart';
import 'package:shimmer/shimmer.dart';

// ignore: must_be_immutable
class HomeTopBar extends PreferredSize {
  final double height;
  final BehaviorSubject<int> percentage;
  final User user;
  HomeTopBar({Key key, this.height, @required this.percentage, @required this.user});

  @override
  Size get preferredSize => Size.fromHeight(height);

  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);

    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            StreamBuilder<int>(
              stream: this.percentage,
              builder: (context, snapshot) {
                if(snapshot.data == null) return SizedBox();
                if(snapshot.data == 0) return SizedBox();
                if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
                return LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
              }
            ),
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                                'assets/logo/logo_white.svg',
                                height: 30,
                                width: 30,
                                color: Colors.black,
                              ),
                ),

                            SizedBox(width: 10),
                Text("Kookers",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: Colors.black)),
              ],
            ),
            Row(
              children: [
                InkWell(
                    onTap: () {
                      if(databaseService.user.value == null){
                        showCupertinoModalBottomSheet(
                          expand: true,
                          context: context,
                          builder: (context) => BeforeSignPage(from: "home"));
                      }else{
                        showCupertinoModalBottomSheet(
                          expand: false,
                          context: context,
                          builder: (context) => HomeSettings(user: this.user,),
                        );
                      }
                    },
                    child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: new BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(CupertinoIcons.slider_horizontal_3,
                            size: 23.0, color: Colors.black))),
                Flexible(
                  child: ListTile(
                    autofocus: false,
                    onTap: () {
                      if(databaseService.user.value == null){
                        showCupertinoModalBottomSheet(
                        expand: true,
                        context: context,
                        builder: (context) => BeforeAdress(isReturn: true),
                      );
                      }else{
                        showCupertinoModalBottomSheet(
                        expand: true,
                        context: context,
                        builder: (context) => HomeSearchPage(isReturn: false, user: this.user,),
                      );
                      }
                    },
                    title: StreamBuilder<UserDef>(
                        initialData: null,
                        stream: databaseService.user$,
                        builder: (context, AsyncSnapshot<UserDef> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return SizedBox(
                                height: 25,
                                width: 400,
                                child: Shimmer.fromColors(
                                    enabled: true,
                                    child: Container(color: Colors.white),
                                    baseColor: Colors.grey[200],
                                    highlightColor: Colors.grey[300]));
                          if(snapshot.data == null) {
                            return StreamBuilder<Adress>(
                              stream: databaseService.adress,
                              builder: (context, snapshot) {
                                if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
                                if(snapshot.data == null) return SizedBox();
                                return Text(
                                snapshot.data.title,
                              style: GoogleFonts.montserrat(fontSize: 17),
                              overflow: TextOverflow.ellipsis);
                              }
                            );
                          }
                          return Text(
                              snapshot.data.adresses
                                  .where((element) => element.isChosed == true)
                                  .first
                                  .title,
                              style: GoogleFonts.montserrat(fontSize: 17),
                              overflow: TextOverflow.ellipsis);
                        }),
                    trailing: Icon(CupertinoIcons.chevron_down,
                        size: 24.0, color: Colors.grey),
                  ),
                )
              ],
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final User user;
  HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}




class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage>  {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  BehaviorSubject<int> percentage = BehaviorSubject<int>.seeded(0);


  @override
  void initState() {
    Future.delayed(Duration.zero, (){
        final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
        Location location = databaseService.user.value == null ? databaseService.adress.value.location : databaseService.user.value.adresses.firstWhere((element) => element.isChosed).location;
        int distance  = databaseService.user.value == null ? 45 : databaseService.user.value.settings.distanceFromSeller;
      databaseService.loadPublication(location, distance);
    });
    super.initState();
  }

  @override
  void dispose() { 
    this.percentage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);

    return Scaffold(
      appBar: HomeTopBar(
        user: this.widget.user,
        percentage: this.percentage,
        height: 121,
      ),

      floatingActionButton: FloatingActionButton(
        key: Key("publish_button"),
        backgroundColor: Color(0xFFF95F5F),
        onPressed: () async {
          if(this.widget.user == null) {
                  showCupertinoModalBottomSheet(
                          expand: false,
                          context: context,
                          builder: (context) => BeforeSignPage(from: "home"));
          }else{
              if(databaseService.user.value.isSeller == false) {
                showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  builder: (context) => GuidelinesToSell(),
                );
            }else{
             Publication publication = await showCupertinoModalBottomSheet(
                  expand: true,
                  context: context,
                  builder: (context) => HomePublish(user: this.widget.user),
              );

              if(publication != null){
                publication.uploadToServer(this.percentage).then((value)  async {
                this.percentage.add(100);
                NotificationPanelService.showSuccess(context, "Votre plat a été publié");
                this.percentage.add(0);
              }).catchError((onError) {
                  NotificationPanelService.showError(context, "Une erreur s'est produite lors de la publication de votre plat, nouvel essai dans 10 secondes");
                  this.percentage.add(0);
                  Future.delayed(Duration(seconds: 10), (){
                    publication.uploadToServer(this.percentage).then((value) async {
                      this.percentage.add(100);
                      NotificationPanelService.showSuccess(context, "Votre plat a été publié");
                      this.percentage.add(0);
                    }).catchError((onError) {
                      NotificationPanelService.showError(context, "Une erreur s'est produite lors de la publication de votre plat, Veuillez reesayer plus tard");
                      this.percentage.add(0);
                    });
                  });
                });
              }
              
            }
          }
        },
        child: Icon(CupertinoIcons.pencil, size: 34.0, color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<List<PublicationHome>>(
            stream: databaseService.publications$,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Shimmer.fromColors(
                    child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (ctx, index) {
                          return FoodItemShimmer();
                        }),
                    baseColor: Colors.grey[200],
                    highlightColor: Colors.grey[300]);
              if (snapshot.hasError) return Text("i've a bad felling");
              if (snapshot.data.isEmpty)
                return SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    controller: this._refreshController,
                    onRefresh: () {
                      Location location = databaseService.user.value == null ? databaseService.adress.value.location : databaseService.user.value.adresses.firstWhere((element) => element.isChosed).location;
                      int distance  = databaseService.user.value == null ? 45 : databaseService.user.value.settings.distanceFromSeller;
                      databaseService.loadPublication(location, distance).then((value) {
                        Future.delayed(Duration(milliseconds: 500))
                            .then((value) {
                          _refreshController.refreshCompleted();
                        });
                      });
                    },
                    child: EmptyViewElse(text: "Aucune vente à proximité"));

              return SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: this._refreshController,
                onRefresh: () {
                  Location location = databaseService.user.value == null ? databaseService.adress.value.location : databaseService.user.value.adresses.firstWhere((element) => element.isChosed).location;
                  int distance  = databaseService.user.value == null ? 45 : databaseService.user.value.settings.distanceFromSeller;
                  databaseService.loadPublication(location, distance).then((value) {
                    Future.delayed(Duration(milliseconds: 500)).then((value) {
                      _refreshController.refreshCompleted();
                    });
                  });
                },
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (ctx, index) {
                    return FoodItem(
                        publication: snapshot.data[index],
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FoodItemChild(
                                      publication: snapshot.data[index], user: this.widget.user,)));
                        });
                  },
                ),
              );
            }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
