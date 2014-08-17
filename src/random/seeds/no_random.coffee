namespace('agt.random')
# Public:
class agt.random.NoRandom
  @include agt.mixins.Cloneable('seed')
  @include agt.mixins.Sourcable('chancejs.NoRandom','seed')
  @include agt.mixins.Formattable('NoRandom','seed')

  ### Public ###

  constructor: (@seed=0) ->

  get: -> @seed
