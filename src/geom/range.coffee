namespace('agt.geom')

class agt.geom.Range
  properties = ['min','max']

  @include agt.mixins.Cloneable()
  @include agt.mixins.Equatable(properties...)
  @include agt.mixins.Formattable(['Range'].concat(properties)...)
  @include agt.mixins.Sourcable(['agt.geom.Range'].concat(properties)...)
  @include agt.mixins.Parameterizable('rangeFrom', {
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
