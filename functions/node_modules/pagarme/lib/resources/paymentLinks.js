/**
 * @name PaymentLinks
 * @description This module exposes functions
 *              related to the `/payment_links` path.
 *
 * @module paymentLinks
 **/

import { cond, has, T, curry } from 'ramda'

import routes from '../routes'
import request from '../request'

const findOne = curry((opts, body) =>
  request.get(opts, routes.paymentLinks.details(body.id), {})
)

const findAll = curry((opts, pagination) =>
  request.get(opts, routes.paymentLinks.base, pagination || {})
)

/**
 * `GET /payment_links`
 * Makes a request to /payment_links or to /payment_links/:id
 *
 * @param {Object} opts An options params which
 *                      is usually already bound
 *                      by `connect` functions.
 *
 * @param {Object} body The payload for the request.
 * {@link https://docs.pagar.me/v2017-08-28/reference#retornando-links-de-pagamento|API Reference for this payload}
 * @param {Number} [body.id] The paymentLink ID. If not sent a
 *                           paymentLink list will be returned instead.
 * @param {Number} [body.count] Pagination option for paymentLink list.
 *                              Number of paymentLink in a page
 * @param {Number} [body.page] Pagination option for paymentLink list.
 *                             The page index.
*/
const find = (opts, body) =>
  cond([
    [has('id'), findOne(opts)],
    [T, findAll(opts)],
  ])(body)

/**
 * `GET /payment_links`
 * Makes a request to /payment_links to get all paymentLinks.
 *
 * @param {Object} opts An options params which
 *                      is usually already bound
 *                      by `connect` functions.
 *
 * @param {Number} [body.count] Pagination option for paymentLink list.
 *                              Number of paymentLink in a page
 * @param {Number} [body.page] Pagination option for paymentLink list.
 *                             The page index.
*/
const all = (opts, body) =>
  findAll(opts, body)

/**
 * `POST /payment_links`
 * Creates a paymentLink from the given payload.
 *
 * @param {Object} opts An options params which
 *                      is usually already bound
 *                      by `connect` functions.
 *
 * @param {Object} body The payload for the request.
 * {@link https://docs.pagar.me/v2017-08-28/reference#criando-um-link-de-pagamento-1|API Reference for this payload}
 *
 * @returns {Promise} Resolves to the result of
 *                    the request or to an error.
 */
const create = (opts, body) =>
  request.post(opts, routes.paymentLinks.base, body)

/**
 * `POST /payment_links/:id/cancel`
 * Cancels a paymentLink from the given id.
 *
 * @param {Object} opts An options params which
 *                      is usually already bound
 *                      by `connect` functions.
 *
 * @param {Number} body.id The paymentLink ID.
 *
 * @returns {Promise} Resolves to the result of
 *                    the request or to an error.
 */
const cancel = (opts, body) =>
  request.post(opts, routes.paymentLinks.cancel(body.id), body)

export default {
  find,
  all,
  create,
  cancel,
}
