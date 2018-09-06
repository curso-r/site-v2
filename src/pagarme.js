exports.handler = function(event, context, callback) {
    var pagarme = require('pagarme');

    pagarme.client.connect({ api_key: 'SUA_API_KEY' })
      .then(client => client.transactions.capture({ id: "TOKEN", amount: 1000 }));
      
    callback(null, {
    statusCode: 200,
    body: "Hello, World"
    });
};
