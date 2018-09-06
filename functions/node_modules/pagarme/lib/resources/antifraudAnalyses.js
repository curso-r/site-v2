/**
 * @name Antifraud Analyses
 * @description This module exposes functions
 *              related to the `/transactions/:transactionId/antifraud_analyses` path.
 *
 * @module antifraudAnalyses
 **/

import {
  both,
  cond,
  curry,
  has,
  omit,
} from 'ramda'

import routes from '../routes'
import request from '../request'

const findAll = curry((opts, body) =>
  request.get(opts, routes.antifraudAnalyses.findAll(body.transactionId), {})
)

const findOne = curry((opts, body) => {
  const { transactionId, id } = body
  return request.get(opts, routes.antifraudAnalyses.find(transactionId, id), {})
})

/**
 * `GET /transactions/:transactionId/antifraud_analyses`
 * Makes a request to /transactions/:transactionId/antifraud_analyses or
 * to /transactions/:transactionId/antifraud_analyses/:id
 *
 * @param {Object} opts - An options params which
 *                      is usually already bound
 *                      by `connect` functions.
 *
 * @param {Object} body - The payload for the request.
 * {@link https://pagarme.readme.io/v1/reference#retornando-uma-análise-antifraude|API Reference for this payload}
 * @param {Number} body.transactionId - A specific transaction ID
 *
 * @param {Number} [body.id] - The antifraud analyses' ID. If not sent,
 *                             a antifraud analyses list will be returned instead.
 */
const find = (opts, body) =>
  cond([
    [both(has('transactionId'), has('id')), findOne(opts)],
    [has('transactionId'), findAll(opts)],
  ])(body)

/**
 * `POST /transactions/:transactionId/antifraud_analyses`
 * Makes a request to /transactions/:transactionId/antifraud_analyses
 *
 * @param {Object} opts - An options params which
 *                      is usually already bound
 *                      by `connect` functions.
 *
 * @param {Object} body - The payload for the request.
 * {@link https://pagarme.readme.io/v1/reference#criando-uma-análise-antifraude|API Reference for this payload}
 * @param {Number} body.transactionId - A specific transaction ID
 *
 * @returns {Promise} Resolves to the result of
 *                    the request or to an error.
 */
const create = (opts, body) => {
  const { transactionId } = body
  return request.post(
    opts,
    routes.antifraudAnalyses.create(transactionId),
    omit(['transactionId'], body)
  )
}

export default {
  find,
  create,
}
