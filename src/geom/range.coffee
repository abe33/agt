{Cloneable, Equatable, Formattable, Sourcable, Parameterizable} = require '../mixins'

module.exports =
class Range
  properties = ['min','max']

  @include Cloneable()
  @include Equatable(properties...)
  @include Formattable(['Range'].concat(properties)...)
  @include Sourcable(['agt.geom.Range'].concat(properties)...)
  @include Parameterizable('rangeFrom', {
    min: -Infinity
    max: Infinity
  })

  constructor: (min=-Infinity, max=Infinity) ->
    {@min, @max} = @rangeFrom(min, max)

  surround: (value) -> @min <= value <= @max

  middle: -> @min + (@max - @min) / 2

  overlap: (range) -> @max > range.min and range.max > @min

  inside: (range) -> @max > range.max and @min < range.min

  interpolate: (value) -> @min + (@max - @min) * value

  size: -> @max - @min
