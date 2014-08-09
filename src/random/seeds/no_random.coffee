# Public:
class agt.random.NoRandom
  @include mixins.Cloneable('seed')
  @include mixins.Sourcable('chancejs.NoRandom','seed')
  @include mixins.Formattable('NoRandom','seed')

  ### Public ###

  constructor: (@seed=0) ->

  get: -> @seed
