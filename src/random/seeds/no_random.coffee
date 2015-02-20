{Cloneable, Sourcable, Formattable} = require '../../mixins'
# Public:
module.exports =
class NoRandom
  @include Cloneable('seed')
  @include Sourcable('chancejs.NoRandom','seed')
  @include Formattable('NoRandom','seed')

  ### Public ###

  constructor: (@seed=0) ->

  get: -> @seed
