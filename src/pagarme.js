exports.handler = function(event, context, callback) {
    var pagarme = require('pagarme');
    
    console.log(event.queryStringParameters.token);

    pagarme.client.connect({ api_key: process.env.PAGARME_API_KEY })
      .then(client => client.transactions.capture({ id: event.data.TOKEN, amount: 1000 }));
      
    callback(null, {
    statusCode: 200,
    body: "Hello, World"
    });
};
