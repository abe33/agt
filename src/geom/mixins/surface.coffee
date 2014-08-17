namespace('agt.geom')
# Public: Every closed geometry should have the properties of a surface.
#
# These properties are:
#
# - **Acreage** - A `Surface` object can express its surface in px<sup>2</sup>.
# - **Inclusiveness** - A `Surface` object can `contains` other geometries
#   inside the bounds of its shape. It also can returns coordinates inside
#   its shape randomly.
#
# ```coffeescript
# class DummySurface
#   @include agt.geom.Surface
#
#   # Your surface implementation
# ```
# <script>window.exampleKey = 'geometry'</script>
class agt.geom.Surface

  ### Public ###

  # Abstract: Returns the surface of the geometry in px<sup>2</sup>.
  #
  # Returns a {Number}.
  acreage: -> null

  # Abstract: Returns a random [Point]{agt.geom.Point} with coordinates
  # inside the geometry shape.
  #
  # <script>drawGeometry(exampleKey, {surface: true})</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  randomPointInSurface: -> null

  # Abstract: Tests if the passed-in coordinates are inside the geometry shape.
  #
  # <script>drawGeometry(exampleKey, {contains: true})</script>
  #
  # x - Either a {Number} for the x coordinate or a [Point]{agt.geom.Point}.
  # y - A {Number} for the y coordinate, used when a {Number} was passed for
  #     the x coordinate as well.
  #
  # Returns a {Boolean}.
  contains: (x, y) -> null

  # Tests if the passed-in geometry is completely contained inside the
  # current geometry shape.
  #
  # <script>drawContainsGeometry(exampleKey)</script>
  #
  # geometry - The [Geometry]{agt.geom.Geometry} to test.
  #
  # Returns a {Boolean}.
  containsGeometry: (geometry) ->
    geometry.points().every (point) => @contains point
