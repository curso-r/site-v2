import {
  always,
  compose,
  equals,
  ifElse,
  pipe,
  propEq,
  replace,
  toString,
} from 'ramda'

const clean = replace(/[^0-9]/g, '')

const lengthIs = compose(always, propEq('length'))

const validateFrom = ifElse(
  equals('amex'),
  lengthIs(4),
  lengthIs(3)
)

const validate = brand => pipe(
  toString,
  clean,
  validateFrom(brand)
)

export default validate
