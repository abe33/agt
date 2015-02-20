{Cloneable, Sourcable, Formattable} = require '../../mixins'
# Public:
module.exports =
class MathRandom
  @include Cloneable()
  @include Sourcable('chancejs.MathRandom')
  @include Formattable('MathRandom')

  # Public:
  get: -> Math.random()
