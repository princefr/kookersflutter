import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Vendor/OrderItemSeller.dart';
import 'package:kookers/Pages/Vendor/PublicationItemVendor.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/PageTitle.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/subjects.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toggle_switch/toggle_switch.dart';


class VendorPage extends StatefulWidget {
   VendorPage({Key key}) : super(key: key);

  @override
  _VendorPageState createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  @override
  void initState() {
    new Future.delayed(Duration.zero, (){
      final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
        databaseService.loadSellerPublications();
        databaseService.loadSellerOrders();
    });
    super.initState();
  }

   final BehaviorSubject<int> initialLabel = BehaviorSubject<int>.seeded(0);

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final RefreshController _refreshController2 =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    //final firebaseUser = context.watch<User>();
    //final storageService = Provider.of<StorageService>(context, listen: false);
    //final authentificationService = Provider.of<AuthentificationService>(context, listen: false);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);

    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Container(
          child: Column(children: [
        PageTitle(title: "Vendeur"),
        SizedBox(height: 20),

        StreamBuilder<int>(
          stream: this.initialLabel.stream,
          builder: (context,AsyncSnapshot<int> snapshot) {
            return ToggleSwitch(
              inactiveBgColor: Colors.grey[300],
              activeBgColor: Color(0xFFF95F5F),
              initialLabelIndex: this.initialLabel.value,
              minWidth: 400,
              labels: ['Publications', 'Commandes'],
              onToggle: (index) {
                this.initialLabel.add(index);
              },
            );
          }
        ),

        SizedBox(height: 20),

        StreamBuilder<int>(
          stream: this.initialLabel.stream,
          builder: (context, AsyncSnapshot<int> snapshot) {
            return Builder(builder: (context) {
              if (snapshot.data == 0) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: StreamBuilder<List<PublicationVendor>>(
                            stream: databaseService.sellerPublications.stream,
                            builder: (context,
                                AsyncSnapshot<List<PublicationVendor>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                return Shimmer.fromColors(
                        child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: (ctx, index) {
                              return PublicationItemVendorShimmer();
                            }),
                        baseColor: Colors.grey[200],
                        highlightColor: Colors.grey[300]);
                              if (snapshot.data.isEmpty)
                                return Text("this is empty");
                              return SmartRefresher(
                                enablePullDown: true,
                                controller: this._refreshController,
                                onRefresh: (){
                                  databaseService.loadSellerPublications().then((value) {
                                    Future.delayed(Duration(milliseconds: 500))
                                        .then((value) {
                                      _refreshController.refreshCompleted();
                                    });
                                  });
                                },
                                child: ListView(
                                  shrinkWrap: true,
                                  children: snapshot.data.map((e) => PublicationItemVendor(publication: e)).toList(),
                                )
                              );
                            })),
                  ),
                );
              } else {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: StreamBuilder<List<OrderVendor>>(
                          stream: databaseService.sellerOrders.stream,
                          builder:
                              (context, AsyncSnapshot<List<OrderVendor>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting)
                              return Shimmer.fromColors(
                        child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: (ctx, index) {
                              return OrderItemSellerShimmer();
                            }),
                        baseColor: Colors.grey[200],
                        highlightColor: Colors.grey[300]);
                            if (snapshot.data.isEmpty) return Text("this is empty");
                            return SmartRefresher(
                              enablePullDown: true,
                              onRefresh: (){
                                databaseService.loadSellerOrders().then((value) {
                                  Future.delayed(Duration(milliseconds: 500))
                                        .then((value) {
                                      _refreshController2.refreshCompleted();
                                    });
                                });
                              },
                              controller: this._refreshController2,
                              child: ListView(
                                shrinkWrap: true,
                                children: snapshot.data.map((e) => OrderItemSeller(vendor: e)).toList(),
                              ),
                            );
                          }),
                    ),
                  ),
                );
              }
            });
          }
        )
      ]));
    });
  }
}


