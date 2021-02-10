import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/EmptyView.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class TransationItemShimmer extends StatelessWidget {
  const TransationItemShimmer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
          child: Icon(
            CupertinoIcons.arrow_down_circle_fill,
            color: Colors.green[200],
            size: 30,
          )),
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: Text("transaction.type",
                    style: GoogleFonts.montserrat(fontSize: 15))),

                    SizedBox(height: 10),
            Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: Text("transaction.id",
                    style: GoogleFonts.montserrat(fontSize: 12))),
          ]),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child:
                    Text("17 €", style: GoogleFonts.montserrat(fontSize: 17))),
                    SizedBox(height: 10),
            Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: Text("11/06/2021",
                    style: GoogleFonts.montserrat(fontSize: 12)))
          ]),
    );
  }
}

class TransationItem extends StatelessWidget {
  final Transaction transaction;
  const TransationItem({Key key, this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: this.transaction.type == "payment"
          ? Icon(
              CupertinoIcons.arrow_down_circle_fill,
              color: Colors.green[200],
              size: 30,
            )
          : Icon(
              CupertinoIcons.arrow_up_right_circle_fill,
              color: Colors.red[200],
              size: 30,
            ),
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(transaction.type, style: GoogleFonts.montserrat(fontSize: 15)),
            Text(transaction.id, style: GoogleFonts.montserrat(fontSize: 12)),
          ]),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              (this.transaction.net / 100).toString() +
                  " " +
                  this.transaction.currencySymbol,
              style: GoogleFonts.montserrat(fontSize: 17),
            ),
            Text(Jiffy.unix(this.transaction.created).yMd,
                style: GoogleFonts.montserrat(fontSize: 12))
          ]),
    );
  }
}

class Balance {
  int currentBalance;
  int pendingBalance;
  double totalBalance;
  String currency;

  Balance(
      {this.currency,
      this.currentBalance,
      this.pendingBalance,
      this.totalBalance});

  static Balance fromJson(Map<String, dynamic> map) => Balance(
      currency: map["currency"],
      pendingBalance: int.parse(map["pending_balance"]),
      currentBalance: int.parse(map["current_balance"]),
      totalBalance: (int.parse(map["pending_balance"]) +
              int.parse(map["current_balance"])) /
          100);
}

class BalancePage extends StatefulWidget {
  final User user;
  BalancePage({Key key, this.user}) : super(key: key);

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void refreshData(context) async {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
    await databaseService.loadUserData(this.widget.user.uid);
    Future.delayed(Duration(microseconds: 300)).then((value) {
      _refreshController.refreshCompleted();
    });
  }






  @override
  void dispose() { 
    super.dispose();
  }


final StreamButtonController _streamButtonController = StreamButtonController();



  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);

      return Scaffold(
          appBar: TopBarWitBackNav(
              title: "Portefeuille",
              rightIcon: CupertinoIcons.exclamationmark_circle_fill,
              isRightIcon: false,
              height: 54,
              onTapRight: () {}),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SmartRefresher(
                    controller: this._refreshController,
                    onRefresh: () {
                      refreshData(context);
                    },
                    child: ListView(
                      children: [
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: Text(
                                "Votre portefeuille représente la somme de vos montants disponibles et de vos montants en attente. Après une vente réussie, il peut s'écouler 7 jours avant que vous ne puissiez retirer votre argent.",
                                style: GoogleFonts.montserrat(
                                    decoration: TextDecoration.none,
                                    color: Colors.black,
                                    fontSize: 10))),
                      ),
                      SizedBox(height: 50),

                      StreamBuilder<UserDef>(
                            stream: databaseService.user,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                            return Shimmer.fromColors(
                                  child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  "100 €",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w500),
                                )),
                          ),
                                  baseColor: Colors.grey[200],
                                  highlightColor: Colors.grey[300]);
                          }

                          
                          return Center(
                                child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: Text(
                                      snapshot.data.balance.totalBalance.toString(),
                                      style: GoogleFonts.montserrat(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w500),
                                    )),
                              );
                            }
                          ),
                        



                      SizedBox(height: 40),

                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Transactions",
                            style: GoogleFonts.montserrat(fontSize: 18)),
                      ),

                      SizedBox(height: 5),
                      Divider(),
                      StreamBuilder<UserDef>(
                          stream: databaseService.user,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return Shimmer.fromColors(
                                  child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                      itemCount: 10,
                                      itemBuilder: (ctx, index) {
                                        return TransationItemShimmer();
                                      }),
                                  baseColor: Colors.grey[200],
                                  highlightColor: Colors.grey[300]);
                            if(snapshot.data.transactions.isEmpty) return EmptyViewElse(text: "Vous n'avez pas de transactions");
                                  
                            return ListView(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: snapshot.data.transactions
                                    .map((e) => TransationItem(transaction: e))
                                    .toList());
                          }),
                    ]),
                  ),
                ),

                

                StreamBuilder<UserDef>(
                  stream: databaseService.user,
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
                    if(snapshot.hasError) return SizedBox();
                    return StreamButton(buttonColor: snapshot.data.balance.totalBalance > 0 ? Color(0xFFF95F5F) : Colors.grey,
                                         buttonText: "Retirer sur mon compte",
                                         errorText: "Une erreur s'est produite, veuillez reessayer",
                                         loadingText: "Retrait  en cours",
                                         successText: "Retrait effectué",
                                          controller: _streamButtonController, onClick: snapshot.data.balance.totalBalance == 0 ? null :  () async {
                                            _streamButtonController.isLoading();
                                            databaseService.makePayout(snapshot.data.balance).then((value) async {
                                              await databaseService.loadUserData(this.widget.user.uid);
                                              _streamButtonController.isSuccess();
                                            }).catchError((onError){
                                               print(onError["exception"]["raw"]["code"]);
                                              _streamButtonController.isError();
                                            });
                                                  
                                            
                                            
                                          });
                  }
                )
              ],
            ),
          ));

  }
}
