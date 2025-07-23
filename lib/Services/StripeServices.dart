import 'package:kookers/Env/Environment.dart';
import 'package:stripe_payment/stripe_payment.dart' as stripe;

class StripeServices {
  void initiateStripe() async {
    stripe.StripePayment.setOptions(StripeOptions(
        publishableKey:
            environment['Stripe'],
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  Future<PaymentMethod> registrarCardWithForm() async {
    return stripe.StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest());
  }

  Future<Token> getSourceFromCard(CreditCard card) async {
    return stripe.StripePayment.createTokenWithCard(card);
  }


  static String getSigle(String code){
    // https://stripe.com/docs/api/balance_transactions/object
    switch (code) {
      case "payment":
          return "Paiement";
      case "payout":
          return "Retrait vers compte";
      case "refound":
          return "Reboursement";
      
      default:
        return "Transaction";
    }
  }

  static String getErrorFromString(String code) {
    // https://stripe.com/docs/error-codes
    switch (code) {
      case "account_already_exists":
        return "Le compte que vous essayer de creer existe deja";
      case "parameter_invalid_integer":
        return "La somme du portefeuille non en attente doit etre superieur à 0";
      case "account_invalid":
          return "Le compte n'est pas valide, veuillez reessayer.";
      case "amount_too_large":
          return "Le montant est trop large";
      case "amount_too_small":
          return "Le montant est trop faible.";
      case "authentication_required":
        return "Une authentification est requise.";
      case "balance_insufficient":
          return "Votre argent disponible pour les retraits est insufissant, veuillez reessayer plus tard.";
      case "bank_account_declined":
        return "Votre compte en banque a été décliné, veuillez reesayer avec un autre.";
      case "bank_account_unusable":
          return "Votre compte en banque est inutilisation, veuillez reesayer avec un autre.";
      case "bank_account_unverified":
          return "Votre compte en banque n'est pas verifié, veuillez reesayer avec un autre.";
      case "bank_account_verification_failed":
          return "La vérification de votre compte a échoué, veuillez reesayer avec un autre.";
      case "card_declined":
          return "Carte refusée, veuillez reessayer avec une autre carte.";
      case "charge_already_captured":
          return "Le paiement a deja été capturé.";
      case "charge_already_refunded":
          return "Le remboursement a deja été effectué";
      case "charge_disputed":
            return "Le paiement est contesté";
      case "charge_exceeds_source_limit":
            return "Carte refusée, limite atteinte, veuillez reessayer avec une autre source.";
      case "charge_expired_for_capture":
            return "La capture du paiement a expiré";
      case "payment_intent_action_required":
            return "Une action est requise";
      case "payment_intent_authentication_failure":
            return "L'authentification a echouée, veuillez reessayer";
      case "payment_intent_incompatible_payment_method":
            return "La methode de paiement est imcompatible, veuillez reessayer";
      case "payment_intent_payment_attempt_failed":
        return "La tentative de paiement a echouée, veuillez reessayer avec une autre carte.";
      case "payment_method_provider_decline":
        return "Le paiement a été refusée, veuillez reessayer avec une autre carte.";
      case "payouts_not_allowed":
          return "Les retraits ne sont pas disponibles, Veuillez reesayer.";
      case "transfers_not_allowed":
            return "Les transfers ne sont pas disponibles, Veuillez reesayer.";
      default:
        return "Une erreur s'est produite, veuillez reessayer.";
    }
  }
}
