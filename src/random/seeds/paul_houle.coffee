namespace('agt.random')
# Original Implementation License:
#
# The Central Randomizer 1.3 (C) 1997 by Paul Houle (paul@honeylocust.com)
# See:  http://www.honeylocust.com/javascript/randomizer.html

# Public:
class agt.random.PaulHoule
  @include agt.mixins.Cloneable('seed')
  @include agt.mixins.Sourcable('chancejs.PaulHoule','seed')
  @include agt.mixins.Formattable('PaulHoule','seed')

  ### Public ###

  constructor: (@seed) ->

  get: ->
    @seed = (@seed * 9301 + 49297) % 233280
    @seed / 233280.0
