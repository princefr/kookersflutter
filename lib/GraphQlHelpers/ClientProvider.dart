import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

String uuidFromObject(Object object) {
  if (object is Map<String, Object>) {
    final String? typeName = object['__typename'] as String?;
    final String? id = object['id']?.toString();
    if (typeName != null && id != null) {
      return <String>[typeName, id].join('/');
    }
  }
  return "";
}

final GraphQLCache cache = GraphQLCache(store: InMemoryStore());

ValueNotifier<GraphQLClient> clientFor({
  required String uri,
  String? subscriptionUri,
  String? authorization
}) {
  Link link = HttpLink(uri);

  if (authorization != null && authorization.isNotEmpty) {
    final AuthLink authLink = AuthLink(
      getToken: () async => authorization,
    );
    link = authLink.concat(link);
  }

  if (subscriptionUri != null && subscriptionUri.isNotEmpty) {
    final WebSocketLink websocketLink = WebSocketLink(
      subscriptionUri,
      config: const SocketClientConfig(
        autoReconnect: true,
        inactivityTimeout: Duration(seconds: 300),
      ),
    );

    link = Link.split(
      (request) => request.isSubscription,
      websocketLink,
      link,
    );
  }

  return ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: cache,
      link: link,
    ),
  );
}

/// Wraps the root application with the `graphql_flutter` client.
/// We use the cache for all state management.
class ClientProvider extends StatelessWidget {
  ClientProvider({
    required this.child,
    required String uri,
    String? subscriptionUri,
  }) : client = clientFor(
          uri: uri,
          subscriptionUri: subscriptionUri,
        );

  final Widget child;
  final ValueNotifier<GraphQLClient> client;

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: child,
    );
  }
}