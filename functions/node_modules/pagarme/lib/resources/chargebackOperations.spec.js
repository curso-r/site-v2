import { merge } from 'ramda'
import Promise from 'bluebird'
import runTest from '../../test/runTest'

test('client.chargebackOperations.find', () => {
  const options = {
    connect: {
      api_key: 'abc123',
    },
    method: 'GET',
    body: {
      api_key: 'abc123',
    },
  }

  const findInTransaction = runTest(merge(options, {
    subject: client => client.chargebackOperations.find({ transactionId: 1234 }),
    url: '/transactions/1234/chargeback_operations',
  }))

  return Promise.props({
    findInTransaction,
  })
})
