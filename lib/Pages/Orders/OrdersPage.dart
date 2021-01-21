

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/PageTitle.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class OrdersPage extends StatefulWidget {
  OrdersPage({Key key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {

    @override
  void initState() {
    new Future.delayed(Duration.zero, (){
      final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
      databaseService.loadbuyerOrders();
    });
    super.initState();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

 @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
    return GraphQLConsumer(builder: (GraphQLClient client) {
   return Container(
      color: Colors.white,
      child: Column(
        children: [
          PageTitle(title: "Mes achats"),
          
          Expanded(
            child: StreamBuilder<List<Order>>(
              stream: databaseService.buyerOrders.stream,
              builder: (context,AsyncSnapshot<List<Order>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                          return LinearProgressIndicator();
                if (snapshot.data.isEmpty) return Text("this is empty");
                return SmartRefresher(
                          enablePullDown: true,
                          controller: this._refreshController,
                          onRefresh: (){
                            databaseService.loadbuyerOrders().then((value) {
                              Future.delayed(Duration(milliseconds: 500))
                                    .then((value) {
                                  _refreshController.refreshCompleted();
                                });
                            });
                          },
                          child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index){
                          return OrderItem(order: snapshot.data[index]);
                    }
                    ),
                     );
              }
            ),
          ),
        ],
      ),
    );

    });
  }
}


