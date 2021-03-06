{Cloneable, Sourcable, Formattable} = require '../../mixins'
# Original Implementation License:
#
# The Central Randomizer 1.3 (C) 1997 by Paul Houle (paul@honeylocust.com)
# See:  http://www.honeylocust.com/javascript/randomizer.html

# Public:
module.exports =
class PaulHoule
  @include Cloneable('seed')
  @include Sourcable('chancejs.PaulHoule','seed')
  @include Formattable('PaulHoule','seed')

  ### Public ###

  constructor: (@seed) ->

  get: ->
    @seed = (@seed * 9301 + 49297) % 233280
    @seed / 233280.0
