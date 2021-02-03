import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Home/FoodIemChild.dart';
import 'package:kookers/Pages/Home/FoodItem.dart';
import 'package:kookers/Pages/Home/HomePublish.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Pages/Home/HomeSettings.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class HomeTopBar extends PreferredSize {
  final double height;
  const HomeTopBar({Key key, this.height});

  @override
  Size get preferredSize => Size.fromHeight(height);

  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);

    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Kookers",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: Colors.black)),
                StreamBuilder(
                    stream: databaseService.user,
                    builder: (context, AsyncSnapshot<UserDef> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return CircularProgressIndicator();
                      if (snapshot.hasError) return Text("i've a bad felling");
                      if (!snapshot.hasData) return Text("its empty out there");
                      return CircleAvatar(
                        radius: 25,
                        backgroundImage: CachedNetworkImageProvider(
                          snapshot.data.photoUrl,
                        ),
                      );
                    })
              ],
            ),
            Row(
              children: [
                InkWell(
                    onTap: () {
                      showCupertinoModalBottomSheet(
                        expand: false,
                        context: context,
                        builder: (context) => HomeSettings(),
                      );
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
                    onTap: () {
                      showCupertinoModalBottomSheet(
                        expand: false,
                        context: context,
                        builder: (context) => HomeSearchPage(isReturn: false),
                      );
                    },
                    title: StreamBuilder(
                        initialData: null,
                        stream: databaseService.user,
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
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);

    return Scaffold(
      appBar: HomeTopBar(
        height: 144,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFF95F5F),
        onPressed: () {
          showCupertinoModalBottomSheet(
            expand: true,
            context: context,
            builder: (context) => HomePublish(),
          );
        },
        child: Icon(CupertinoIcons.pencil, size: 34.0, color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          controller: this._refreshController,
          onRefresh: () {
            databaseService.loadPublication().then((value) {
              Future.delayed(Duration(milliseconds: 500)).then((value) {
                _refreshController.refreshCompleted();
              });
            });
          },
          child: StreamBuilder<List<PublicationHome>>(
              stream: databaseService.publications$,
              initialData: databaseService.publications.value,
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
                if (snapshot.data.isEmpty) return Text("its empty out there");
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (ctx, index) {
                    return FoodItem(
                          publication: snapshot.data[index],
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FoodItemChild(publication: snapshot.data[index])));
                          });
                  },
                );
              }),
        ),
      ),
    );
  }
}
