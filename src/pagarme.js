exports.handler = function(event, context, callback) {
    var pagarme = require('pagarme');
    
    var token = event.queryStringParameters.token;
    console.log('Received token: ', token);
    

    //pagarme.client.connect({ api_key: process.env.PAGARME_API_KEY })
    //  .then(client => client.transactions.capture({ id: event.data.TOKEN, amount: 1000 }));
      
    pagarme.client.connect({ api_key: 'ak_test_ntiFjO9hdZo6K1IcZYRhJ8hyIrpPXH' })
      .then(client => client.transactions.capture({ id: token, amount: 1000 }));
      //.then(response => console.log(response))
      //.catch(error => console.error(error));
    
    console.log(response);
    
    callback(null, {
    statusCode: 200,
    body: "Hello, World"
    });
};
