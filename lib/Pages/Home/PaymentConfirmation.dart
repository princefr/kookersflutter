import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kookers/Models/PaymentModels.dart';
import 'package:kookers/Pages/PaymentMethods/PaymentMethodPage.dart';
import 'package:kookers/Services/AnalyticsService.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Haptics.dart';
import 'package:kookers/Services/CurrencyService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/StripeServices.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TipSelector.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class PaymentConfirmation extends StatefulWidget {
  final User user;
  final OrderInput order;
  PaymentConfirmation({Key? key, required this.order, required this.user})
      : super(key: key);

  @override
  _PaymentConfirmationState createState() => _PaymentConfirmationState();
}

class _PaymentConfirmationState extends State<PaymentConfirmation> {
  final stripeService = StripeServices();

  /// Currently-selected tip amount, in the order's currency.
  /// Added by the tipping feature (FEATURE_PROPOSALS.md §6.4).
  num _tip = 0;

  @override
  void initState() {
    new Future.delayed(Duration.zero, () {
      stripeService.initiateStripe();
    });
    KookersEvents.startCheckout(
        publicationId: widget.order.publication?.id ?? '');
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
                            child: Text('payment.summary'.tr(),
                                style: GoogleFonts.montserrat(fontSize: 22))),
                      ),
                      SizedBox(height: 30),
                      ListTile(
                        autofocus: false,
                        leading: Icon(CupertinoIcons.location_solid),
                        title: Text(
                            databaseService.user.value.adresses
                                    ?.where(
                                        (element) => element.isChosed == true)
                                    .first
                                    .title ??
                                '',
                            style: GoogleFonts.montserrat()),
                      ),
                      ListTile(
                        autofocus: false,
                        leading: Icon(CupertinoIcons.calendar),
                        title: Text(
                            Jiffy.parse(this.widget.order.deliveryDay)
                                .format(pattern: "do MMMM yyyy [ À ] HH:mm"),
                            style: GoogleFonts.montserrat()),
                      ),
                      ListTile(
                        autofocus: false,
                        leading: Text(
                            "x" + this.widget.order.quantity.toString(),
                            style: GoogleFonts.montserrat(
                                fontSize: 20, color: Colors.green)),
                        title: Text(this.widget.order.title ?? '',
                            style: GoogleFonts.montserrat()),
                        trailing: Text(
                            (this.widget.order.totalPrice) +
                                " " +
                                CurrencyService.getCurrencySymbol(
                                    this.widget.order.currency),
                            style: GoogleFonts.montserrat(fontSize: 20)),
                      ),
                      ListTile(
                        autofocus: false,
                        leading: Icon(CupertinoIcons.exclamationmark_circle),
                        title: Text('payment.serviceFee'.tr(),
                            style: GoogleFonts.montserrat()),
                        trailing: Text(
                            (this.widget.order.fees ?? '') +
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
                                'payment.sameDayNotice'.tr(),
                                style: GoogleFonts.montserrat(
                                    decoration: TextDecoration.none,
                                    color: Colors.black,
                                    fontSize: 10))),
                      ),
                      ListTile(
                        autofocus: false,
                        leading: Text(
                          'payment.total'.tr(),
                          style: GoogleFonts.montserrat(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                            (this.widget.order.totalWithFees ?? '') +
                                " " +
                                CurrencyService.getCurrencySymbol(
                                    this.widget.order.currency),
                            style: GoogleFonts.montserrat(
                                fontSize: 20, color: Colors.green)),
                      ),
                      // ---- Tip selector (FEATURE_PROPOSALS.md §6.4) ----
                      TipSelector(
                        subtotal: num.tryParse(
                                this.widget.order.totalWithFees ?? '') ??
                            0,
                        currencySymbol: CurrencyService.getCurrencySymbol(
                            this.widget.order.currency ?? ''),
                        onChanged: (amount) {
                          setState(() => _tip = amount);
                          if (amount > 0) {
                            KookersEvents.tipSelected(amount: amount);
                          }
                        },
                      ),
                      if (_tip > 0)
                        ListTile(
                          autofocus: false,
                          leading: Text(
                            'payment.tipTitle'.tr(),
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                          trailing: Text(
                            '$_tip ${CurrencyService.getCurrencySymbol(this.widget.order.currency ?? '')}',
                            style: GoogleFonts.montserrat(fontSize: 14),
                          ),
                        ),
                      ListTile(
                        autofocus: false,
                        leading: Text(
                          'payment.grandTotal'.tr(),
                          style: GoogleFonts.montserrat(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '${(num.tryParse(this.widget.order.totalWithFees ?? '') ?? 0) + _tip} ${CurrencyService.getCurrencySymbol(this.widget.order.currency ?? '')}',
                          style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: KookersColors.primary),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('payment.paymentMethods'.tr(),
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
                              if (snapshot.data?.allCards?.isEmpty ?? true)
                                return ListTile(
                                  autofocus: false,
                                  leading: Icon(CupertinoIcons.creditcard),
                                  trailing: Icon(CupertinoIcons.plus),
                                  title: Text('payment.addMethod'.tr()),
                                  onTap: () {
                                    Get.to(PaymentMethodPage(
                                      user: this.widget.user,
                                    ));
                                  },
                                );

                              CardModel cardChosed = snapshot.data!.allCards!
                                  .firstWhere((element) =>
                                      element.id ==
                                      databaseService.user.value.defaultSource);

                              return ListTile(
                                  autofocus: false,
                                  trailing: Icon(
                                    CupertinoIcons.check_mark_circled,
                                    color: Colors.green,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                PaymentMethodPage(
                                                    user: this.widget.user)));
                                  },
                                  leading: SvgPicture.asset(
                                    'assets/payments_logo/${cardChosed.brand ?? 'base'}.svg',
                                    height: 30,
                                  ),
                                  title: Text(cardChosed.last4 ?? ''));
                            }),
                      ),
                      SizedBox(height: 45),
                      StreamButton(
                          buttonColor: Colors.black,
                          buttonText: 'payment.payAmount'.tr() +
                              " " +
                              (this.widget.order.totalWithFees ?? '') +
                              "€",
                          errorText: 'common.error'.tr(),
                          loadingText: 'payment.buying'.tr(),
                          successText: 'payment.bought'.tr(),
                          controller: _streamButtonController,
                          onClick: () async {
                            await Haptics.medium();
                            _streamButtonController.isLoading();
                            databaseService
                                .createOrder(this.widget.order)
                                .then((value) async {
                              databaseService.loadbuyerOrders();
                              await _streamButtonController.isSuccess();
                              await Haptics.success();
                              await KookersEvents.purchaseSuccess(
                                transactionId: widget.order.id ?? '',
                                currency: widget.order.currency ?? 'EUR',
                                value: (num.tryParse(
                                            widget.order.totalWithFees ??
                                                '') ??
                                        0) +
                                    _tip,
                                tip: _tip > 0 ? _tip : null,
                              );
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
