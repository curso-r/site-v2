import Promise from 'bluebird'
import { merge } from 'ramda'

import runTest from '../../test/runTest'

test('client.antifraudAnalyses.find', () => {
  const options = {
    connect: {
      api_key: 'abc123',
    },
    method: 'GET',
    body: {
      api_key: 'abc123',
    },
  }

  const findAll = runTest(merge(options, {
    subject: client => client.antifraudAnalyses.find({ transactionId: 5432 }),
    url: '/transactions/5432/antifraud_analyses',
  }))

  const find = runTest(merge(options, {
    subject: client => client.antifraudAnalyses.find({ transactionId: 5432, id: 1234 }),
    url: '/transactions/5432/antifraud_analyses/1234',
  }))

  return Promise.props({
    findAll,
    find,
  })
})

test('client.antifraudAnalyses.create', () => {
  const options = {
    connect: {
      api_key: 'abc123',
    },
    method: 'POST',
  }

  const approved = runTest(merge(options, {
    subject: client => client.antifraudAnalyses.create({ transactionId: 5432, status: 'approved' }),
    url: '/transactions/5432/antifraud_analyses',
    body: {
      api_key: 'abc123',
      status: 'approved',
    },
  }))

  const refused = runTest(merge(options, {
    subject: client => client.antifraudAnalyses.create({ transactionId: 5432, status: 'refused' }),
    url: '/transactions/5432/antifraud_analyses',
    body: {
      api_key: 'abc123',
      status: 'refused',
    },
  }))

  return Promise.props({
    approved,
    refused,
  })
})
