import 'package:flutter/material.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/EmptyView.dart';
import 'package:kookers/Widgets/PageTitle.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class RoomsPage extends StatefulWidget {
  RoomsPage({Key key}) : super(key: key);

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage>
    with AutomaticKeepAliveClientMixin<RoomsPage> {
  @override
  void initState() {
    Future.delayed(Duration.zero, (){
        final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
          databaseService.loadrooms();
    });
    super.initState();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
    return Container(
        child: Column(
      children: [
        PageTitle(title: "Messages"),
        Divider(),
        Expanded(
          child: StreamBuilder<List<Room>>(
              initialData: databaseService.rooms.value,
              stream: databaseService.rooms.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Shimmer.fromColors(
                      child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (ctx, index) {
                            return RoomItemShimmer();
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
                        databaseService.loadrooms().then((value) {
                          Future.delayed(Duration(milliseconds: 500))
                              .then((value) {
                            _refreshController.refreshCompleted();
                          });
                        });
                      },
                      child:
                          EmptyViewElse(text: "Vous n'avez pas de messages."));
                return SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  controller: this._refreshController,
                  onRefresh: () {
                    databaseService.loadrooms().then((value) {
                      Future.delayed(Duration(milliseconds: 500)).then((value) {
                        _refreshController.refreshCompleted();
                      });
                    });
                  },
                  child: ListView.builder(
                      
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return RoomItem(
                          room: snapshot.data[index],
                          index: index,
                        );
                      }),
                );
              }),
        ),
      ],
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
