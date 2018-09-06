import {
  __,
  addIndex,
  allPass,
  ap,
  apply,
  both,
  complement,
  equals,
  either,
  isEmpty,
  length,
  map,
  modulo,
  nth,
  pipe,
  replace,
  split,
  subtract,
  sum,
  take,
  toString,
} from 'ramda'

// CNPJ = String of length 14
// CPF = String of length 11
// ID = CNPJ or CPF
// RAW_ID = ID before special characters cleanup
// DIGIT = Number from 0 to 9

const repeatedNumberRegex = /^(.)\1+$/

const mapIndexed = addIndex(map)

const weigthMasks = {
  // for cpf
  9: [10, 9, 8, 7, 6, 5, 4, 3, 2],
  10: [11, 10, 9, 8, 7, 6, 5, 4, 3, 2],
  // for cnpj
  12: [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2],
  13: [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2],
}

// String -> String
const clean = replace(/[^\d]+/g, '')

// [String] -> ID -> Boolean
const hasOnlyOneNumber = subject => repeatedNumberRegex.test(subject)

// ID -> Boolean
const hasValidForm = complement(either(isEmpty, hasOnlyOneNumber))

// [Number] -> ID -> DIGIT
const generateDigitWithMask = mask => pipe(
  take(length(mask)),
  split(''),
  mapIndexed((el, i) => el * mask[i]),
  sum,
  modulo(__, 11),
  subtract(11, __)
)

// Number -> ID -> DIGIT
const digit = index => pipe(
  nth(index),
  Number
)

// Number -> ID -> Boolean
const validateDigit = index => subject =>
  apply(
    equals,
    ap([
      digit(index),
      generateDigitWithMask(weigthMasks[index], index),
    ], [subject])
  )

// [Number] -> ID -> [Number] -> ID -> Boolean
const validateDigits = pipe(
  ap([validateDigit]),
  allPass
)

// [Number] -> ID -> Boolean
const validateId = indexes => pipe(
  toString,
  clean,
  both(hasValidForm, validateDigits(indexes))
)

// ID -> Boolean
export const cnpj = validateId([12, 13])

// ID -> Boolean
export const cpf = validateId([9, 10])

