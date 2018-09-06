/**
 * @name login
 * @memberof strategies
 * @private
 */
import { merge } from 'ramda'

import session from '../../resources/session'

const buildSessionAuth = ({ session_id }, headers) => ({
  body: { session_id },
  headers,
})

/**
 * Creates a session in the server
 * and returns a Promise with the
 * pertinent object.
 * Allows setting the environment
 * to live passing `environment: "live"`.
 *
 * @param {any} { email, password, environment }
 * @returns {Promise} Resolves to an object
 *                    containing a body with
 *                    the desired `session_id`
 * @private
 */
function execute ({ email, password, environment }) {
  const headers = environment === 'live'
    ? { 'X-Live': 1 }
    : {}

  return session.create({ headers }, email, password)
    .then(sessionInfo => ({
      options: buildSessionAuth(sessionInfo, headers),
      authentication: sessionInfo,
    }))
}

/**
 * Returns the supplied parameter with
 * the `execute` function added to it.
 *
 * @param {any} options
 * @returns {Object} The `options` parameter
 *                   with `execute` add to it
 * @private
 */
function build (options) {
  return merge(options, { execute: execute.bind(null, options) })
}

export default { build }
