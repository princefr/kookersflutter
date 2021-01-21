import 'package:stripe_payment/stripe_payment.dart';

class StripeServices {
  void initiateStripe() async {
        StripePayment.setOptions(
        StripeOptions(publishableKey: "pk_test_51623aEF9cRDonA7mYkDijtSwyubt71keNBa6qMq7zvO9knDpy6ZzYyQEN9YeqLzUJqGm237vJN09eJYwGmEE07EQ00J4LDb1yK", merchantId: "Test", androidPayMode: 'test'));
  }


  Future<PaymentMethod> registrarCardWithForm() async {
    return StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
  }



  Future<Token> getSourceFromCard(CreditCard card) async {
    return StripePayment.createTokenWithCard(card);
  }




}