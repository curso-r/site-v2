import runTest from '../../test/runTest'

test('client.chargebacks', () =>
  runTest({
    connect: {
      api_key: 'abc123',
    },
    subject: client => client.chargebacks.find({
      transaction_id: '123',
    }),
    method: 'GET',
    url: '/chargebacks',
    body: {
      api_key: 'abc123',
    },
  })
)
