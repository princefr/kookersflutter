import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/PageTitle.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class RoomsPage extends StatefulWidget {
  RoomsPage({Key key}) : super(key: key);

  @override
  _RoomsPageState createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> with AutomaticKeepAliveClientMixin<RoomsPage> {




  @override
  void initState() {
    super.initState();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);

    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Container(
          child: Column(
        children: [
          PageTitle(title: "Messages"),
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
                  if(snapshot.hasError) return Text("i've a bad felling");
                  if(snapshot.data.isEmpty) return Text("its empty out there");
                  return SmartRefresher(
                    enablePullDown: true,
                    controller: this._refreshController,
                    onRefresh: () {
                      databaseService.loadrooms().then((value) {
                        Future.delayed(Duration(milliseconds: 500))
                            .then((value) {
                          _refreshController.refreshCompleted();
                        });
                      });
                    },
                    child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return RoomItem(room: snapshot.data[index], index: index,);
                        }),
                  );
                }),
          ),
        ],
      ));
    });
  }

  @override
bool get wantKeepAlive => true;
}
