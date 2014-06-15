# Original Implementation License:
#
# The Central Randomizer 1.3 (C) 1997 by Paul Houle (paul@honeylocust.com)
# See:  http://www.honeylocust.com/javascript/randomizer.html

# Public:
class agt.random.PaulHoule
  @include mixins.Cloneable('seed')
  @include mixins.Sourcable('chancejs.PaulHoule','seed')
  @include mixins.Formattable('PaulHoule','seed')

  ### Public: Instances Methods ###
  constructor: (@seed) ->
  get: ->
    @seed = (@seed * 9301 + 49297) % 233280
    @seed / 233280.0
