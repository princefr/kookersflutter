
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/KookersButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';


class Balance {
  String currentBalance;
  String pendingBalance;
  String currency;


  Balance({this.currency, this.currentBalance, this.pendingBalance});


  static Balance fromJson(Map<String, dynamic> map) => Balance(
    currency: map["currency"],
    pendingBalance: map["pending_balance"],
    currentBalance: map["current_balance"]
  );


}

class BalancePage extends StatefulWidget {
  BalancePage({Key key}) : super(key: key);

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {


@override
  void initState() {
    new Future.delayed(Duration.zero, (){
      final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
      databaseService.getBalanceTransactions();
    });
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Scaffold(
          appBar: TopBarWitBackNav(
            title: "Portefeuille",
            rightIcon: CupertinoIcons.exclamationmark_circle_fill,
            isRightIcon: false,
            height: 54,
            onTapRight: () {}),

          body: SafeArea(
              child: Container(
            child: Column(children: [
              Divider(),

                Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.",
                  style: GoogleFonts.montserrat(
                      decoration: TextDecoration.none,
                      color: Colors.black,
                      fontSize: 10))),
                          ),

            SizedBox(height: 50),
            Expanded(
              child: Query(
                options: QueryOptions(documentNode: gql(r'''
                        query GetAcountBalance($account_id: String!) {
                              accountbalance(account_id: $account_id) {
                                current_balance
                                pending_balance
                                currency
                              }
                          }
                        '''), variables: <String, String>{
                  "account_id": databaseService.user.value.stripeaccountId,
                }),

                builder: (result, {fetchMore, refetch}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }

                  if (result.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if(result.data == null){
                    return Text("no data");
                  }

                  

                  Balance balance = Balance.fromJson(result.data["accountbalance"]);
                  //String symbol = NumberFormat.currency(name: databaseService.user.value.currency).currencySymbol;

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                              color: Colors.green[200],
                            ),
                          padding: EdgeInsets.all(5),
                          
                          child: Text("Disponible")),

                          Text(balance.currentBalance, style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.w600),),
                      ],
                    ),


                    
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                              color: Colors.grey[300],
                            ),
                          padding: EdgeInsets.all(5),
                          child: Text("En attente")),
                          Text(balance.pendingBalance, style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.w600),),
                      ],
                    ),
                    
                  ],),);
                },
              ),
            ),

            

            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: KookersButton(
                    text: "Retirer",
                    color: Colors.black,
                    textcolor: Colors.white),
              ),
            )
        ]),
      ),
          ));
    });
  }
}
