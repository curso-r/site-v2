/**
 * @name Chargeback Operations
 * @description This module exposes functions
 *              related to chargeback operations.
 *
 * @module chargebackOperations
 **/

import { curry } from 'ramda'

import routes from '../routes'
import request from '../request'

/**
 * `GET /transactions/:transaction_id/chargeback_operations`
 *
 * @param {Object} opts An options params which
 *                      is usually already bound
 *                      by `connect` functions.
 *
 * @param {Object} body The payload for the request.
 * @param {Number} [body.transactionId] A transaction ID to get all
 *                                      the chargeback operations.
*/
const find = curry((opts, body) =>
  request.get(opts, routes.chargebackOperations.transaction(body.transactionId), {}))


export default {
  find,
}
