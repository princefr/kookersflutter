import 'package:flutter/material.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/EmptyView.dart';
import 'package:kookers/Widgets/PageTitle.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class OrdersPage extends StatefulWidget {
  OrdersPage({Key key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage> {
  @override
  void initState() {
    new Future.delayed(Duration.zero, () {
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
      databaseService.loadbuyerOrders();
    });
    super.initState();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          PageTitle(title: "Mes achats"),
          Divider(),
          Expanded(
            child: StreamBuilder<List<Order>>(
                stream: databaseService.buyerOrders.stream,
                builder: (context, AsyncSnapshot<List<Order>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Shimmer.fromColors(
                        child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: (ctx, index) {
                              return OrderItemShimmer();
                            }),
                        baseColor: Colors.grey[200],
                        highlightColor: Colors.grey[300]);
                  if (snapshot.data.isEmpty)
                    return SmartRefresher(
                        enablePullDown: true,
                        controller: this._refreshController,
                        onRefresh: () {
                          databaseService.loadbuyerOrders().then((value) {
                            Future.delayed(Duration(milliseconds: 1000))
                                .then((value) {
                              _refreshController.refreshCompleted();
                            });
                          });
                        },
                        child: EmptyView());
                  return SmartRefresher(
                    enablePullDown: true,
                    controller: this._refreshController,
                    onRefresh: () {
                      databaseService.loadbuyerOrders().then((value) {
                        Future.delayed(Duration(milliseconds: 1000))
                            .then((value) {
                          _refreshController.refreshCompleted();
                        });
                      });
                    },
                    child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return OrderItem(order: snapshot.data[index]);
                        }),
                  );
                }),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
