
const bool isProduction = bool.fromEnvironment('dart.vm.product');




// testing config.
const testConfig = {
  'graphqlUrl': 'https://b0adbeebbb8a.ngrok.io/graphql',
  'graphqlSocket': 'wss://b0adbeebbb8a.ngrok.io/graphql',
  'Stripe': 'pk_test_51623aEF9cRDonA7mYkDijtSwyubt71keNBa6qMq7zvO9knDpy6ZzYyQEN9YeqLzUJqGm237vJN09eJYwGmEE07EQ00J4LDb1yK'
};


// production config.
const productionConfig = {
  'graphqlUrl': 'https://kookers-app.herokuapp.com/graphql',
  'graphqlSocket': 'wss://kookers-app.herokuapp.com/graphql',
  'Stripe': 'pk_live_51623aEF9cRDonA7m0j7VeY8CApcImsaqjOLeTNOTnFyk5YLO0TkiJzRNHzjNebJIKy873E7tsq1TZV1rMRUPbY3Z00ouKCSe2r'
};

final environment = isProduction ? productionConfig : testConfig;
