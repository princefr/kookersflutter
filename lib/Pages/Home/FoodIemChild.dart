import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Messages/FullScreenImage.dart';
import 'package:kookers/Pages/PaymentMethods/CreditCardItem.dart';
import 'package:kookers/Pages/PaymentMethods/PaymentMethodPage.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/OrderProvider.dart';
import 'package:kookers/Services/StripeServices.dart';
import 'package:kookers/Widgets/ConfirmationDialog.dart';
import 'package:kookers/Widgets/InfoDialog.dart';
import 'package:kookers/Widgets/KookersButton.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

// ignore: must_be_immutable
class ChooseDatePage extends StatelessWidget {
  CupertinoDatePickerMode datemode;
  ChooseDatePage({Key key, @required this.datemode}) : super(key: key);

  DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 420,
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
            SizedBox(height: 30),
            Expanded(
              child: CupertinoDatePicker(
                  use24hFormat: true,
                  mode: this.datemode,
                  minimumDate: DateTime.now().add(Duration(hours: 3)),
                  initialDateTime: DateTime.now().add(Duration(hours: 3)),
                  onDateTimeChanged: (DateTime newDateTime) {
                    this.date = newDateTime;
                  }),
            ),
            SizedBox(height: 20),
            FlatButton(
                onPressed: () {
                  Navigator.pop(context, this.date);
                },
                child: KookersButton(
                    text: "Choisir",
                    color: Colors.black,
                    textcolor: Colors.white)),
            SizedBox(height: 20),
          ],
        ));
  }
}

// ignore: must_be_immutable
class Stepper extends StatefulWidget {
  final BehaviorSubject<int> quantity;
  Stepper({Key key, this.quantity}) : super(key: key);
  @override
  _StepperState createState() => _StepperState();
}

class _StepperState extends State<Stepper> {
  void upNumber() {
    setState(() {
      this.widget.quantity.add(this.widget.quantity.value + 1);
    });
  }

  void downNumber() {
    setState(() {
      if (this.widget.quantity.value != 0) {
        this.widget.quantity.add(this.widget.quantity.value - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125.0,
      height: 54.0,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17.0), color: Colors.black),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        InkWell(
          onTap: () {
            this.downNumber();
          },
          child: Container(
            height: 30.0,
            width: 30.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0), color: Colors.black),
            child: Center(
              child: Icon(
                Icons.remove,
                color: Colors.white,
                size: 25.0,
              ),
            ),
          ),
        ),
        Text(this.widget.quantity.value.toString(),
            style: GoogleFonts.montserrat(fontSize: 19, color: Colors.white)),
        InkWell(
          onTap: () {
            this.upNumber();
          },
          child: Container(
            height: 30.0,
            width: 30.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0), color: Colors.black),
            child: Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 25.0,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class FoodItemChild extends StatefulWidget {
  final PublicationHome publication;
  FoodItemChild({Key key, @required this.publication}) : super(key: key);

  @override
  _FoodItemChildState createState() => _FoodItemChildState();
}

class _FoodItemChildState extends State<FoodItemChild> {
  int quantity = 0;
  List<String> tagfood = ['Végétarien', 'Vegan'];
  List<String> foodpreferences = [
    'Végétarien',
    'Vegan',
    'Sans gluten',
    'Hallal',
    'Adapté aux allergies alimentaires'
  ];

  final stripeService = StripeServices();

  double percentage(percent, total) {
    return (percent / 100) * total;
  }

  StreamButtonController _streamButtonController = StreamButtonController();

  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);
    final orderProvider = Provider.of<OrderProvider>(context, listen: true);


      return Scaffold(
        appBar: TopBarWitBackNav(
            title: this.widget.publication.title,
            isRightIcon: true,
            height: 54,
            rightIcon: CupertinoIcons.heart),
        body: Container(
          child: ListView(children: [
            CarouselSlider(
                items: this.widget.publication.photoUrls.map((e) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => FullScreenImage(url: e)));
                    },
                    child: Hero(
                      tag: e,
                      child: Image(
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(e),
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 300.0,
                  aspectRatio: 16 / 9,
                  enlargeCenterPage: true,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                )),
            Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(this.widget.publication.pricePerAll,
                      style: GoogleFonts.montserrat(
                          fontSize: 26, color: Colors.grey)),
                )),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stepper(quantity: orderProvider.quantity)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(this.widget.publication.description),
            ),
            Container(
              height: 40,
              child: Builder(builder: (BuildContext ctx) {
                if (this
                    .widget
                    .publication
                    .preferences
                    .any((element) => element.isSelected == true)) {
                  return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: this
                          .widget
                          .publication
                          .preferences
                          .where((element) => element.isSelected == true)
                          .toList()
                          .length,
                      itemBuilder: (ctx, index) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(left: 5, right: 5, top: 3),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              padding: EdgeInsets.all(10),
                              child: Text(this
                                  .widget
                                  .publication
                                  .preferences
                                  .where(
                                      (element) => element.isSelected == true)
                                  .elementAt(index)
                                  .title)),
                        );
                      });
                } else {
                  return Container(
                    height: 40,
                    child: Text("Sans préférences"),
                    decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  );
                }
              }),
            ),
            

            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Text("Periode de retrait commande", style: GoogleFonts.montserrat(decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 15))
            ),

            Divider(),
            StreamBuilder<DateTime>(
                stream: orderProvider.deliveryDate.stream,
                builder: (context, AsyncSnapshot<DateTime> snapshot) {
                  return ListTile(
                    onTap: () async {
                      DateTime date = await showCupertinoModalBottomSheet(
                        expand: false,
                        context: context,
                        builder: (context) => ChooseDatePage(datemode: CupertinoDatePickerMode.dateAndTime),
                      );

                      orderProvider.deliveryDate.add(date);
                    },
                    leading: Icon(CupertinoIcons.calendar),
                    title: Text("Retrait"),
                    trailing: Text(snapshot.data.toString()),
                  );
                }),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam",
                      style: GoogleFonts.montserrat(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 10))),
            ),
            SizedBox(
              height: 30,
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
            SizedBox(
              height: 10,
            ),
            Container(
              child: StreamBuilder(
                  stream: databaseService.sources.stream,
                  builder: (context, AsyncSnapshot<List<CardModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return LinearProgressIndicator();
                    if (snapshot.data.isEmpty)
                      return ListTile(
                        leading: Icon(CupertinoIcons.creditcard),
                        trailing: Icon(CupertinoIcons.plus),
                        title: Text("Ajouter un moyen de paiement"),
                        onTap: () {
                          stripeService
                              .registrarCardWithForm()
                              .then((paymentMethod) {
                            databaseService
                                .addattachPaymentToCustomer(paymentMethod.id)
                                .then((value) {
                              databaseService.loadSourceList();
                            });
                          });
                        },
                      );

                    CardModel cardChosed = snapshot.data.firstWhere((element) =>
                        element.id == databaseService.user.value.defaultSource);

                    return ListTile(
                        trailing: Icon(
                          CupertinoIcons.check_mark_circled,
                          color: Colors.green,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => PaymentMethodPage()));
                        },
                        leading: SvgPicture.asset(
                                'assets/payments_logo/${cardChosed.brand}.svg',
                                height: 30,
                              ),
                        title: Text(cardChosed.last4));
                  }),
            ),

            SizedBox(height: 15),

            ListTile(
                leading: InkWell(onTap: (){
                                showDialog(context: context,
                                       builder: (context) => InfoDialog(infoText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam"));
                              }, child: Icon(CupertinoIcons.info_circle)),
                title : Text("Frais de service"),
                trailing: Text("3%")
              ),

            SizedBox(
              height: 30,
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(this.widget.publication.seller.photoUrl),
              ),
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    this.widget.publication.seller.firstName +
                        " " +
                        this.widget.publication.seller.lastName,
                    style: GoogleFonts.montserrat()),
              ),
            ),
            Divider(),

            SizedBox(height: 20),
            
            StreamBuilder(
                stream: orderProvider.isAllFilled$,
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  return StreamButton(
                      buttonColor: snapshot.data != null
                          ? Color(0xFFF95F5F)
                          : Colors.grey,
                      buttonText: "Acheter",
                      errorText: "Une erreur s'est produite",
                      loadingText: "Achat en cours",
                      successText: "Plat acheté",
                      controller: _streamButtonController,
                      onClick: () async {
                        showDialog(context: context,
                                       builder: (context) => ConfirmationDialog(infoText: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam", onAcceptTap: (){},));
                        
                        // if (snapshot.data != null) {
                        //   _streamButtonController.isLoading();
                        //   final total = orderProvider.quantity.value * 15;
                        //   final totalPlusFees =
                        //       total + this.percentage(20, total).toInt();
                        //   final order = await orderProvider.validate(
                        //       databaseService,
                        //       this.widget.publication,
                        //       totalPlusFees);
                        //   databaseService
                        //       .createOrder(order)
                        //       .then((value) =>
                        //           {_streamButtonController.isSuccess()})
                        //       .catchError((onError) {
                        //     _streamButtonController.isError();
                        //   });
                        // }
                      });
                }),
          ]),
        ),
      );

  }
}
