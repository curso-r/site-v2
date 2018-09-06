class ApiError extends Error {
  constructor (response) {
    super('Pagar.me API error. Check error\'s "response" property for more details.')
    this.name = 'ApiError'
    this.response = response
  }
}

export default ApiError
