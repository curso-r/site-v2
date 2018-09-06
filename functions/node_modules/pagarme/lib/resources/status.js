/**
 * @name Status
 * @description This module exposes functions
 *              related to the `/status` route.
 *
 * @module status
 **/

import routes from '../routes'
import request from '../request'

/**
 * `POST /status`
 * Returns the service status and environment.
 *
 * @returns {Promise} Resolves to the result of
 *                    the request or to an error.
 */
const status = opts => request.get(opts, routes.status)

export default status

