import 'package:stripe_payment/stripe_payment.dart';

class StripeServices {
  void initiateStripe() async {
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            "pk_test_51623aEF9cRDonA7mYkDijtSwyubt71keNBa6qMq7zvO9knDpy6ZzYyQEN9YeqLzUJqGm237vJN09eJYwGmEE07EQ00J4LDb1yK",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  Future<PaymentMethod> registrarCardWithForm() async {
    return StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
  }

  Future<Token> getSourceFromCard(CreditCard card) async {
    return StripePayment.createTokenWithCard(card);
  }


  static String getSigle(String code){
    // https://stripe.com/docs/api/balance_transactions/object
    switch (code) {
      case "payment":
          return "Paiement";
        break;
      case "payout":
          return "Retrait vers compte";
        break;
      case "refound":
          return "Reboursement";
        break;
      
      default:
        return "Transaction";
    }
  }

  static String getErrorFromString(String code) {
    // https://stripe.com/docs/error-codes
    switch (code) {
      case "account_already_exists":
        return "Le compte que vous essayer de creer existe deja";
        break;
      case "account_invalid":
          return "Le compte n'est pas valide, veuillez reessayer.";
        break;
      case "amount_too_large":
          return "Le montant est trop large";
        break;
      case "amount_too_small":
          return "Le montant est trop faible.";
        break;
      case "authentication_required":
        return "Une authentification est requise.";
        break;
      case "balance_insufficient":
          return "Votre argent disponible pour les retraits est insufissant, veuillez reessayer plus tard.";
        break;
      case "bank_account_declined":
        return "Votre compte en banque a été décliné, veuillez reesayer avec un autre.";
        break;
      case "bank_account_unusable":
          return "Votre compte en banque est inutilisation, veuillez reesayer avec un autre.";
        break;
      case "bank_account_unverified":
          return "Votre compte en banque n'est pas verifié, veuillez reesayer avec un autre.";
        break;
      case "bank_account_verification_failed":
          return "La vérification de votre compte a échoué, veuillez reesayer avec un autre.";
        break;
      case "card_declined":
          return "Carte refusée, veuillez reessayer avec une autre carte.";
        break;
      case "charge_already_captured":
          return "Le paiement a deja été capturé.";
        break;
      case "charge_already_refunded":
          return "Le remboursement a deja été effectué";
        break;
      case "charge_disputed":
            return "Le paiement est contesté";
        break;
      case "charge_exceeds_source_limit":
            return "Carte refusée, limite atteinte, veuillez reessayer avec une autre source.";
        break;
      case "charge_expired_for_capture":
            return "La capture du paiement a expiré";
        break;
      case "payment_intent_action_required":
            return "Une action est requise";
        break;
      case "payment_intent_authentication_failure":
            return "L'authentification a echouée, veuillez reessayer";
        break;
      case "payment_intent_incompatible_payment_method":
            return "La methode de paiement est imcompatible, veuillez reessayer";
        break;
      case "payment_intent_payment_attempt_failed":
        return "La tentative de paiement a echouée, veuillez reessayer avec une autre carte.";
        break;
      case "payment_method_provider_decline":
        return "Le paiement a été refusée, veuillez reessayer avec une autre carte.";
        break;
      case "payouts_not_allowed":
          return "Les retraits ne sont pas disponibles, Veuillez reesayer.";
        break;
      case "transfers_not_allowed":
            return "Les transfers ne sont pas disponibles, Veuillez reesayer.";
        break;
      default:
        return "Une erreur s'est produite, veuillez reessayer.";
    }
  }
}
