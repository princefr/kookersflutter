import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Models/User.dart';
import 'package:kookers/Models/Balance.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  final GraphQLClient client;
  
  // ignore: close_sinks
  BehaviorSubject<UserDef> _user = BehaviorSubject<UserDef>();
  Stream<UserDef> get user$ => _user.stream.asBroadcastStream();
  UserDef? get currentUser => _user.value;

  UserService({required this.client});

  void dispose() {
    _user.add(null);
  }

  void setUser(UserDef user) {
    _user.add(user);
  }

  Future<String> updateDefaultSource(String source) async {
    final MutationOptions _options = MutationOptions(
      documentNode: gql(r"""
        mutation UpdateDefaultSource($userId: String!, $source: String!){
          updateDefaultSource(userId: $userId, source: $source)
        }
      """),
      variables: <String, String>{
        "userId": currentUser!.id,
        "source": source,
      }
    );

    return await client.mutate(_options).then((result) => result.data["updateDefaultSource"]);
  }

  Future<String> updateIbanDeposit(String iban) async {
    final MutationOptions _options = MutationOptions(
      documentNode: gql(r"""
        mutation UpdateIbanSource($userId: String!, $iban: String!){
          updateIbanSource(userId: $userId, iban: $iban)
        }
      """),
      variables: <String, String>{
        "userId": currentUser!.id,
        "iban": iban,
      }
    );

    return await client.mutate(_options).then((result) => result.data["updateIbanSource"]);
  }

  Future<String> updateFirebasetoken(String token) async {
    final MutationOptions _options = MutationOptions(
      documentNode: gql(r"""
        mutation UpdateFirebasetoken($userId: String!, $token: String!){
          updateFirebasetoken(userId: $userId, token: $token)
        }
      """),
      variables: <String, String>{
        "userId": currentUser!.id,
        "token": token,
      }
    );

    return await client.mutate(_options).then((result) => result.data["updateFirebasetoken"]);
  }

  Future<UserDef?> loadUserData(String uid) {
    final QueryOptions _options = QueryOptions(
      fetchPolicy: FetchPolicy.cacheAndNetwork,
      documentNode: gql(r"""
        query GetIfUSerExist($uid: String!) {
          usersExist(firebase_uid: $uid){
            _id
            email
            first_name
            last_name
            is_seller
            phonenumber
            customerId
            country
            currency
            default_source
            default_iban
            stripe_account
            notificationPermission
            settings {
              food_preferences
              food_price_ranges
              distance_from_seller
              updatedAt
            }
            stripeAccount {
              charges_enabled
              payouts_enabled
              requirements {
                currently_due
                eventually_due
                past_due
                pending_verification
                disabled_reason
                current_deadline
              }
            }
            balance {
              current_balance
              pending_balance
              currency
            }
            transactions {
              id
              object
              amount
              available_on
              created
              currency
              description
              fee
              net
              reporting_category
              type
              status
            }
            all_cards {
              id
              brand
              country
              customer
              cvc_check
              exp_month
              exp_year
              fingerprint
              funding
              last4
            }
            ibans {
              id
              object
              account_holder_name
              account_holder_type
              bank_name
              country
              currency
              last4
            }
            createdAt
            photoUrl
            updatedAt
            adresses {title, location {latitude, longitude}, is_chosed}
            fcmToken
          }
        }
      """), 
      variables: <String, String>{"uid": uid}
    );

    return client.query(_options).then((kooker) {
      if (kooker.data["usersExist"] != null) {
        final kookersUser = UserDef.fromJson(kooker.data["usersExist"]);
        setUser(kookersUser);
        return kookersUser;
      }
      return null;
    });
  }

  Future<UserDef?> setIsSeller() async {
    final MutationOptions _options = MutationOptions(
      documentNode: gql(r"""
        mutation SetIsSeller($userId: String!){
          setIsSeller(userId: $userId) {
            _id
            email
            first_name
            last_name
            phonenumber
            customerId
            country
            currency
            default_source
            default_iban
            stripe_account
            is_seller
            settings {
              food_preferences
              food_price_ranges  
              distance_from_seller
              updatedAt
            }
            stripeAccount {
              charges_enabled
              payouts_enabled
              requirements {
                currently_due
                eventually_due
                past_due
                pending_verification
                disabled_reason
                current_deadline
              }
            }
            balance {
              current_balance
              pending_balance
              currency
            }
            transactions {
              id
              object
              amount
              available_on
              created
              currency
              description
              fee
              net
              reporting_category
              type
              status
            }
            all_cards {
              id
              brand
              country
              customer
              cvc_check
              exp_month
              exp_year
              fingerprint
              funding
              last4
            }
            ibans {
              id
              object
              account_holder_name
              account_holder_type
              bank_name
              country
              currency
              last4
            }
            createdAt
            photoUrl
            updatedAt
            adresses {title, location {latitude, longitude}, is_chosed}
            fcmToken
          }
        }
      """),
      variables: <String, String>{"userId": currentUser!.id}
    );

    return client.mutate(_options).then((kooker) {
      if (kooker.data["setIsSeller"] != null) {
        final kookersUser = UserDef.fromJson(kooker.data["setIsSeller"]);
        setUser(kookersUser);
        return kookersUser;
      }
      return null;
    });
  }
}