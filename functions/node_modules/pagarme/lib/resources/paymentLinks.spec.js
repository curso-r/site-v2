import Promise from 'bluebird'
import { merge } from 'ramda'

import runTest from '../../test/runTest'

test('client.paymentLinks.cancel', () =>
  runTest({
    connect: {
      api_key: 'abc123',
    },
    subject: client => client.paymentLinks.cancel({ id: 1234 }),
    method: 'POST',
    url: '/payment_links/1234/cancel',
    body: {
      api_key: 'abc123',
    },
  })
)

test('client.paymentLinks.create', () =>
  runTest({
    connect: {
      api_key: 'abc123',
    },
    subject: client => client.paymentLinks.create({
      amount: 1000,
      items: [
        {
          id: '1',
          title: 'Bola de futebol',
          unit_price: 400,
          quantity: 1,
          tangible: true,
        },
        {
          id: 'a123',
          title: 'Caderno do Goku',
          unit_price: 600,
          quantity: 1,
          tangible: true,
        },
      ],
    }),
    method: 'POST',
    url: '/payment_links',
    body: {
      api_key: 'abc123',
      amount: 1000,
      items: [
        {
          id: '1',
          title: 'Bola de futebol',
          unit_price: 400,
          quantity: 1,
          tangible: true,
        },
        {
          id: 'a123',
          title: 'Caderno do Goku',
          unit_price: 600,
          quantity: 1,
          tangible: true,
        },
      ],
    },
  })
)

const findOptions = {
  connect: {
    api_key: 'abc123',
  },
  method: 'GET',
  body: {
    api_key: 'abc123',
  },
}

test('client.paymentLinks.find', () => {
  const find = runTest(merge(findOptions, {
    subject: client => client.paymentLinks.find({ id: 1337 }),
    url: '/payment_links/1337',
  }))

  const findAll = runTest(merge(findOptions, {
    subject: client => client.paymentLinks.find({ count: 10, page: 2 }),
    url: '/payment_links',
  }))

  return Promise.props({
    find,
    findAll,
  })
})

test('client.paymentLinks.all', () =>
  runTest(merge(findOptions, {
    subject: client => client.paymentLinks.all({ count: 10, page: 2 }),
    url: '/payment_links',
  }))
)
