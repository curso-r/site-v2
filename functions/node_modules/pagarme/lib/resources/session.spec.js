import runTest from '../../test/runTest'

test('client.session.create', () =>
  runTest({
    connect: {
      api_key: 'abc123',
    },
    subject: client => client.session.create('test@email.com', 'strongpasswordtrustme'),
    method: 'POST',
    url: '/sessions',
    body: {
      api_key: 'abc123',
      email: 'test@email.com',
      password: 'strongpasswordtrustme',
    },
  })
)

test('client.session.verify', () =>
  runTest({
    connect: {
      api_key: 'abc123',
    },
    subject: client => client.session.verify({ id: 1234, password: 'strongpasswordtrustme'}),
    method: 'POST',
    url: '/sessions/1234/verify',
    body: {
      api_key: 'abc123',
      id: 1234,
      password: 'strongpasswordtrustme',
    },
  })
)
test('client.session.destroy', () =>
  runTest({
    connect: {
      api_key: 'abc123',
    },
    subject: client => client.session.destroy(1234),
    method: 'DELETE',
    url: '/sessions/1234',
    body: {
      api_key: 'abc123',
    },
  })
)
