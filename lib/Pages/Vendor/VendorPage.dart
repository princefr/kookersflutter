import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Pages/Vendor/OrderItemSeller.dart';
import 'package:kookers/Pages/Vendor/PublicationItemVendor.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/EmptyView.dart';
import 'package:kookers/Widgets/PageTitle.dart';
import 'package:kookers/Widgets/Toogle.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rxdart/subjects.dart';
import 'package:shimmer/shimmer.dart';

class VendorPubView extends StatefulWidget {
  VendorPubView({Key key}) : super(key: key);

  @override
  _VendorPubViewState createState() => _VendorPubViewState();
}

class _VendorPubViewState extends State<VendorPubView>
    with AutomaticKeepAliveClientMixin<VendorPubView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);
    return Container(
      child: Container(
          child: StreamBuilder<List<PublicationVendor>>(
              stream: databaseService.sellerPublications.stream,
              initialData: databaseService.sellerPublications.value,
              builder:
                  (context, AsyncSnapshot<List<PublicationVendor>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Shimmer.fromColors(
                      child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (ctx, index) {
                            return PublicationItemVendorShimmer();
                          }),
                      baseColor: Colors.grey[200],
                      highlightColor: Colors.grey[300]);
                if(snapshot.hasError) return Text("i've a bad felling");
                if(snapshot.data.isEmpty) return SmartRefresher(
                  enablePullDown: true,
                    controller: this._refreshController,
                    onRefresh: () {
                      databaseService.loadSellerPublications().then((value) {
                        Future.delayed(Duration(milliseconds: 500))
                            .then((value) {
                          _refreshController.refreshCompleted();
                        });
                      });
                    },child: EmptyViewElse(text: "Vous n'avez aucun plat publié."));
                return SmartRefresher(
                    enablePullDown: true,
                    controller: this._refreshController,
                    onRefresh: () {
                      databaseService.loadSellerPublications().then((value) {
                        Future.delayed(Duration(milliseconds: 500))
                            .then((value) {
                          _refreshController.refreshCompleted();
                        });
                      });
                    },
                    child: ListView(
                      shrinkWrap: true,
                      children: snapshot.data
                          .map((e) => PublicationItemVendor(publication: e))
                          .toList(),
                    ));
              })),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class VendorSellView extends StatefulWidget {
  VendorSellView({Key key}) : super(key: key);

  @override
  _VendorSellViewState createState() => _VendorSellViewState();
}

class _VendorSellViewState extends State<VendorSellView>
    with AutomaticKeepAliveClientMixin<VendorSellView> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);
        
    return Container(
      child: StreamBuilder<List<OrderVendor>>(
          initialData: databaseService.sellerOrders.value,
          stream: databaseService.sellerOrders.stream,
          builder: (context, AsyncSnapshot<List<OrderVendor>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Shimmer.fromColors(
                  child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (ctx, index) {
                        return OrderItemSellerShimmer();
                      }),
                  baseColor: Colors.grey[200],
                  highlightColor: Colors.grey[300]);
            if(snapshot.hasError) return Text("i've a bad felling");
                              if(snapshot.data.isEmpty) return SmartRefresher(
                                controller: this._refreshController,
                                enablePullDown: true,
                                onRefresh: () {
                                  databaseService.loadSellerOrders().then((value) {
                                    Future.delayed(Duration(milliseconds: 500)).then((value) {
                                      _refreshController.refreshCompleted();
                                    });
                                  });
                                },
                                child: EmptyViewElse(text: "Vous n'avez aucune commande."));
            return SmartRefresher(
              enablePullDown: true,
              onRefresh: () {
                databaseService.loadSellerOrders().then((value) {
                  Future.delayed(Duration(milliseconds: 500)).then((value) {
                    _refreshController.refreshCompleted();
                  });
                });
              },
              controller: this._refreshController,
              child: ListView(
                shrinkWrap: true,
                children: snapshot.data
                    .map((e) => OrderItemSeller(vendor: e))
                    .toList(),
              ),
            );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class VendorPage extends StatefulWidget {
  VendorPage({Key key}) : super(key: key);

  @override
  _VendorPageState createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage>
    with AutomaticKeepAliveClientMixin<VendorPage> {
  // ignore: close_sinks
  final BehaviorSubject<int> initialLabel = BehaviorSubject<int>.seeded(0);
  PageController _controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        child: Column(children: [
      PageTitle(title: "Ventes"),
      Divider(),
      SizedBox(height: 20),

      StreamBuilder<int>(
          initialData: this.initialLabel.value,
          stream: this.initialLabel.stream,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) return LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
            if (snapshot.hasError) return Text("i've a bad felling");
            if (!snapshot.hasData)
                        return Text("its empty out there");
            return ToggleSwitch(
              inactiveBgColor: Colors.grey[300],
              activeBgColor: Color(0xFFF95F5F),
              initialLabelIndex: this.initialLabel.value,
              minWidth: 400,
              labels: ['Publications', 'Commandes'],
              onToggle: (index) {
                this.initialLabel.add(index);
                this._controller.jumpToPage(index);
              },
            );
          }),

      SizedBox(height: 20),
      Expanded(
        child: PageView(
          
          physics: NeverScrollableScrollPhysics(),
          controller: this._controller,
          children: [VendorPubView(), VendorSellView()],
        ),
      )
    ]));
  }

  @override
  bool get wantKeepAlive => true;
}
