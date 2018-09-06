/**
 * @name Chargebacks
 * @description This module exposes functions
 *              related to the `/chargebacks` path.
 *
 * @module chargebacks
 **/

import routes from '../routes'
import request from '../request'

/**
 * `GET /chargebacks`
 * Finds chargebacks
 *
 * @param {Object} opts An options params which
 *                      is usually already bound
 *                      by `connect` functions.
 * @param {Object} query The query object to be sent.
 * {@link https://pagarme.readme.io/v1/reference#retornando-chargebacks|API Reference for this payload}
 * @returns {Promise} Resolves to the result of
 *                    the request or to an error.
 */
const find = (opts, query) =>
  request.get(opts, routes.chargebacks, query)

export default {
  find,
}
