import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Vendor/VendorPageChild.dart';
import 'package:kookers/Pages/Vendor/VendorPubChild.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/PageTitle.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/subjects.dart';
import 'package:toggle_switch/toggle_switch.dart';

class PublicationItemVendor extends StatelessWidget {
  final PublicationVendor publication;
  const PublicationItemVendor({Key key, this.publication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListTile(
      onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) =>
                  VendorPubPage(publication: this.publication))),
      leading: Image(
          height: 350,
          width: 100,
          fit: BoxFit.cover,
          image: NetworkImage(this.publication.photoUrls[0])),
      title: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text(this.publication.title),
        Text(this.publication.id, style: GoogleFonts.montserrat(fontSize: 13)),
        Text(this.publication.adress.title)
        //Text(this.publicati)
      ]),
    ));
  }
}

class OrderItemSeller extends StatelessWidget {
  final OrderVendor vendor;
  const OrderItemSeller({Key key, this.vendor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
          child: ListTile(
        onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => VendorPageChild(vendor: this.vendor))),
        leading: Image(
            height: 350,
            width: 100,
            fit: BoxFit.cover,
            image: NetworkImage(this.vendor.publication.photoUrls[0])),
        title: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(this.vendor.publication.title),
          Text(this.vendor.productId,
              style: GoogleFonts.montserrat(fontSize: 13)),
        ]),
      )),
    );
  }
}


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
                                return LinearProgressIndicator();
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
                                child: ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (ctx, index) {
                                      return PublicationItemVendor(
                                          publication: snapshot.data[index]);
                                    }),
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
                              return LinearProgressIndicator();
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
                              child: ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (ctx, index) {
                                    return OrderItemSeller(
                                        vendor: snapshot.data[index]);
                                  }),
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


