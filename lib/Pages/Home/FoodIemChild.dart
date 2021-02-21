import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Pages/Home/PaymentConfirmation.dart';
import 'package:kookers/Pages/Messages/FullScreenImage.dart';
import 'package:kookers/Pages/Reports/ReportPage.dart';
import 'package:kookers/Services/CurrencyService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/OrderProvider.dart';
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
                  minimumDate: datemode == CupertinoDatePickerMode.date ? null : DateTime.now().add(Duration(hours: 3)) ,
                  initialDateTime: datemode == CupertinoDatePickerMode.date ? null : DateTime.now().add(Duration(hours: 3)),
                  onDateTimeChanged: (DateTime newDateTime) {
                    this.date = newDateTime;
                  }),
            ),
            SizedBox(height: 20),
            TextButton(
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

class Stepper extends StatefulWidget {
  final BehaviorSubject<int> quantity;
  Stepper({Key key, this.quantity}) : super(key: key);
  @override
  _StepperState createState() => _StepperState();
}




class _StepperState extends State<Stepper> {
  @override
  void dispose() { 
    super.dispose();
  }
  void upNumber() {
    setState(() {
      this.widget.quantity.add(this.widget.quantity.value + 1);
    });
  }

  void downNumber() {
    setState(() {
      if (this.widget.quantity.value != 0 && this.widget.quantity.value != null) {
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




    double percentage(percent, total) {
      return (percent / 100) * total;
    }
  

  double percentage2(x, percent, total) {
    return ((percent / 100) * total) * x;
  }





  @override
  void initState() { 
    super.initState();
    
  }

  StreamButtonController _streamButtonController = StreamButtonController();


  

  OrderProvider orderProvider =  OrderProvider();
  BehaviorSubject<int> serviceFees = BehaviorSubject<int>.seeded(15);
  Stream<double> get feePaid => CombineLatestStream([orderProvider.quantity$, serviceFees.stream], (values) => percentage2(values[0], int.parse(this.widget.publication.pricePerAll), int.parse(values[0]))).asBroadcastStream();
  Stream<double> get total => CombineLatestStream([orderProvider.quantity$, feePaid], (values) => values[0] * int.parse(this.widget.publication.pricePerAll) + values[1]).asBroadcastStream();



  @override
  void dispose() { 
    this.orderProvider.dispose();
    this.serviceFees.close();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);


      return Scaffold(
        appBar: TopBarWitBackNav(
            title: this.widget.publication.title,
            isRightIcon: false,
            height: 54,
            rightIcon: CupertinoIcons.heart),

        body: ListView(
          shrinkWrap: true,
          children: [
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
                child: Text(this.widget.publication.pricePerAll + " " + CurrencyService.getCurrencySymbol(this.widget.publication.currency),
                    style: GoogleFonts.montserrat(
                        fontSize: 26, color: Colors.grey)),
              )),
              
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stepper(quantity: orderProvider.quantity)),
            ],
          ),
          

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              
              Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(children: [
                                    Icon(CupertinoIcons.star_fill, size: 13, color: Colors.yellow[900]),
                                    SizedBox(width: 5),
                                    Text(this.widget.publication.getRating().toStringAsFixed(2) + " " + "(" + this.widget.publication.rating.ratingCount.toString() + ")", style: GoogleFonts.montserrat(fontSize: 17),)
                                  ],),
                                ),
                                Expanded(child: SizedBox()),
                                
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
                  .preferences.length > 0) {
                return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: this
                        .widget
                        .publication
                        .preferences
                        .length,
                    itemBuilder: (ctx, index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 5, right: 5, top: 3),
                        child: Chip(
                            backgroundColor: Colors.green[100],
                            label: Text(this
                                .widget
                                .publication
                                .preferences[index])),
                      );
                    });
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Align(alignment: Alignment.centerLeft, child: Chip(label: Text("Sans préférences"), backgroundColor: Colors.green[100])),
                );
              }
            }),
          ),
          

          SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Text("Periode de livraison", style: GoogleFonts.montserrat(decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: 15))
          ),

          Divider(),
          StreamBuilder<DateTime>(
              stream: orderProvider.deliveryDate.stream,
              builder: (context, AsyncSnapshot<DateTime> snapshot) {
                return ListTile(
                  autofocus: false,
                  onTap: () async {
                    DateTime date = await showCupertinoModalBottomSheet(
                      expand: false,
                      context: context,
                      builder: (context) => ChooseDatePage(datemode: CupertinoDatePickerMode.dateAndTime),
                    );

                    orderProvider.deliveryDate.add(date);
                  },
                  leading: Icon(CupertinoIcons.calendar),
                  title: Text(Jiffy(snapshot.data).format("do MMMM yyyy [ À ] HH:mm"), style: GoogleFonts.montserrat()),
                );
              }),

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

          SizedBox(
            height: 30,
          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 17),
                          child: Text("Adresse de livraison", style: GoogleFonts.montserrat(decoration: TextDecoration.none,
                                      color: Colors.black,
                                      fontSize: 15))
                        ),
                            Divider(),

                                                        ListTile(
                                                          autofocus: false,
                              onTap: (){showCupertinoModalBottomSheet(
                          expand: false,
                          context: context,
                          builder: (context) => HomeSearchPage(isReturn: false,),
                        );},
                              leading: Icon(CupertinoIcons.home),
                              title: StreamBuilder(
                                stream: databaseService.user$,
                                builder: (context, AsyncSnapshot<UserDef> snapshot) {
                                  if(snapshot.connectionState == ConnectionState.waiting) return LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                                  return Text(snapshot.data.adresses.where((element) => element.isChosed == true).first.title, style: GoogleFonts.montserrat(fontSize: 17));
                                }
                              ),
                              trailing: Icon(CupertinoIcons.chevron_down),
                            ),
          SizedBox(
            height: 30,
          ),

          ListTile(
            autofocus: false,
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
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
          
          StreamBuilder(
              stream: orderProvider.quantity$,
              builder: (context, AsyncSnapshot<int> snapshot) {
                return StreamButton(
                    buttonColor: snapshot.data == null ? Colors.grey : snapshot.data > 0 ? Colors.black : Colors.grey,
                    buttonText: "Continuer",
                    errorText: "Une erreur s'est produite",
                    loadingText: "Achat en cours",
                    successText: "Plat acheté",
                    controller: _streamButtonController,
                    onClick: () async {
                      if(snapshot.data != null){
                          final order = await orderProvider.validate(databaseService, this.widget.publication);
                              showCupertinoModalBottomSheet(
                                          expand: true,
                                          context: context,
                                          builder: (context) => PaymentConfirmation(order: order),
                                      );
                      }
                      
                    });
              }),

              SizedBox(height: 20,),


              InkWell(child:Center(child: Text("Signaler", style: GoogleFonts.montserrat(color: Colors.red, fontSize: 18))), onTap: (){
                showCupertinoModalBottomSheet(
                  expand: false,
                  context: context,
                  builder: (context) => ReportPage(publicatonId: this.widget.publication.id, seller: this.widget.publication.seller.id,),
                );
              },),

              SizedBox(height: 10,)
        ]),
      );

  }
}
