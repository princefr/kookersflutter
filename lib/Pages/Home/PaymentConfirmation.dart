import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kookers/Pages/PaymentMethods/CreditCardItem.dart';
import 'package:kookers/Pages/PaymentMethods/PaymentMethodPage.dart';
import 'package:kookers/Services/CurrencyService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/StripeServices.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:provider/provider.dart';

class PaymentConfirmation extends StatefulWidget {
  final OrderInput order;
  PaymentConfirmation({Key key, @required this.order}) : super(key: key);

  @override
  _PaymentConfirmationState createState() => _PaymentConfirmationState();
}

class _PaymentConfirmationState extends State<PaymentConfirmation> {
  final stripeService = StripeServices();

  @override
  void initState() {
    new Future.delayed(Duration.zero, () {
      stripeService.initiateStripe();
    });
    super.initState();
  }

  StreamButtonController _streamButtonController = StreamButtonController();

  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: true,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: 7,
                      width: 80),
                ),
                SizedBox(height: 20),


                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                        child: Center(
                            child: Text("Récapitulatif",
                                style: GoogleFonts.montserrat(fontSize: 22))),
                      ),
                      
                      SizedBox(height: 30),
                      ListTile(
                        leading: Icon(CupertinoIcons.location_solid),
                        title: Text(
                            databaseService.user.value.adresses
                                .where((element) => element.isChosed == true)
                                .first
                                .title,
                            style: GoogleFonts.montserrat()),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.calendar),
                        title: Text(
                            Jiffy(this.widget.order.deliveryDay)
                                .format("do MMMM yyyy [ À ] HH:mm"),
                            style: GoogleFonts.montserrat()),
                      ),
                      ListTile(
                        leading: Text(
                            "x" + this.widget.order.quantity.toString(),
                            style: GoogleFonts.montserrat(
                                fontSize: 20, color: Colors.green)),
                        title: Text(this.widget.order.title,
                            style: GoogleFonts.montserrat()),
                        trailing: Text(
                            this.widget.order.totalPrice +
                                " " +
                                CurrencyService.getCurrencySymbol(
                                    this.widget.order.currency),
                            style: GoogleFonts.montserrat(fontSize: 20)),
                      ),
                      ListTile(
                        leading: Icon(CupertinoIcons.exclamationmark_circle),
                        title: Text("Frais de service",
                            style: GoogleFonts.montserrat()),
                        trailing: Text(
                            this.widget.order.fees +
                                " " +
                                CurrencyService.getCurrencySymbol(
                                    this.widget.order.currency),
                            style: GoogleFonts.montserrat(fontSize: 20)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "Si vous commandez le jour même , l'application prévoit 3 heures de délai pour pouvoir laisser du temps au chef d'acheter des ingrédients frais et de le cuisiner sans stress.",
                                style: GoogleFonts.montserrat(
                                    decoration: TextDecoration.none,
                                    color: Colors.black,
                                    fontSize: 10))),
                      ),
                      ListTile(
                        leading: Text(
                          "Total",
                          style: GoogleFonts.montserrat(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                            this.widget.order.totalWithFees +
                                " " +
                                CurrencyService.getCurrencySymbol(
                                    this.widget.order.currency),
                            style: GoogleFonts.montserrat(
                                fontSize: 20, color: Colors.green)),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Méthodes de paiements",
                                style: GoogleFonts.montserrat(
                                    decoration: TextDecoration.none,
                                    color: Colors.black,
                                    fontSize: 15))),
                      ),
                      Divider(),
                      Container(
                        child: StreamBuilder<UserDef>(
                            stream: databaseService.user$,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                return LinearProgressIndicator(
                                    backgroundColor: Colors.black,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white));
                              if (snapshot.data.allCards.isEmpty)
                                return ListTile(
                                  leading: Icon(CupertinoIcons.creditcard),
                                  trailing: Icon(CupertinoIcons.plus),
                                  title: Text("Ajouter un moyen de paiement"),
                                  onTap: () {
                                    stripeService
                                        .registrarCardWithForm()
                                        .then((paymentMethod) {
                                      databaseService
                                          .addattachPaymentToCustomer(
                                              paymentMethod.id)
                                          .then((value) {
                                        databaseService
                                            .updatedDefaultSource(
                                                paymentMethod.id)
                                            .then((value) async {
                                          databaseService.user.value
                                              .defaultSource = paymentMethod.id;
                                          await databaseService.loadUserData();
                                        });
                                      });
                                    }).catchError((onError) {
                                      print(onError);
                                    });
                                  },
                                );

                              CardModel cardChosed = snapshot.data.allCards
                                  .firstWhere((element) =>
                                      element.id ==
                                      databaseService.user.value.defaultSource);

                              return ListTile(
                                  trailing: Icon(
                                    CupertinoIcons.check_mark_circled,
                                    color: Colors.green,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                PaymentMethodPage()));
                                  },
                                  leading: SvgPicture.asset(
                                    'assets/payments_logo/${cardChosed.brand}.svg',
                                    height: 30,
                                  ),
                                  title: Text(cardChosed.last4));
                            }),
                      ),


                      SizedBox(height: 45),
                      

                      StreamButton(
                          buttonColor: Colors.black,
                          buttonText: "Payer" +
                              " " +
                              this.widget.order.totalWithFees +
                              "€",
                          errorText: "Une erreur s'est produite",
                          loadingText: "Achat en cours",
                          successText: "Plat acheté",
                          controller: _streamButtonController,
                          onClick: () async {
                            _streamButtonController.isLoading();
                            databaseService
                                .createOrder(this.widget.order)
                                .then((value) async {
                              await _streamButtonController.isSuccess();
                              Navigator.pop(context);
                            }).catchError((onError) {
                              _streamButtonController.isError();
                            });
                          }),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
