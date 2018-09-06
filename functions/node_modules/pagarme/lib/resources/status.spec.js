import runTest from '../../test/runTest'

test('client.status', () =>
  runTest({
    connect: {
      api_key: 'abc123',
    },
    method: 'GET',
    url: '/status',
    body: {
      api_key: 'abc123',
    },
    subject: client => client.status(),
  })
)
