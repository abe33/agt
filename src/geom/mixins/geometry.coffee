
# Public: The `Geometry` mixin describes the most basic interface a geometry
# should implements.
#
# ```coffeescript
# class DummyGeometry
#   @include agt.geom.Geometry
#
#   # Your geometry implementation...
# ```
#
# ### Shape
#
# A geometry has a shape constituted by an {Array} of [Points]{agt.geom.Point}. # These points can be accessed using the {::points} method
#
# A geometry can be either opened or closed. It can be retrieved using
# the {::closedGeometry} method.
#
# ### Bounds
#
# A geometry has bounds, represented by the {::left}, {::right}, {::top}
# and {::bottom} methods. An object with the bounds value can be retrieved
# using the {::bounds} method, and the [Rectangle]{agt.geom.Rectangle} formed
# by the geometry bounds can be retrieved using the {::boundingBox} method.
#
# The default bounds computation consist in looking for every points
# of the geometry shape and detect the minimal and maximal values
# on each axis.
# Generally the concrete geometry classes override the bounds methods
# to provide a faster implementation.
#
# ### Drawing API
#
# Every geometries provide basic methods to draw themselves on a canvas,
# {::stroke} and {::fill}, the latter renders a line when the former
# renders a plain shape.
#
# Behind the hood, these two methods relies on the {::drawPath} method that
# actually draw the shape in the canvas context. You can just override this
# method when you need to draw the shape in a specific way.
class agt.geom.Geometry

  ### Public ###

  # **Abstract** - Returns an {Array} of [Points]{agt.geom.Point}
  # constituting the geometry.
  #
  # Returns an {Array} of [Points]{agt.geom.Point}.
  points: ->

  # **Abstract** - Returns a {Boolean} of whether the points forms
  # a closed geometry.
  #
  # Returns a {Boolean}.
  closedGeometry: -> false

  # Internal: The `pointsBounds` private utility is meant to provide
  # the default bounds computation for a geometry, subclasses should
  # implements their own bounds methods if a faster implementation exist.
  pointsBounds = (points, mode, axis) ->
    Math[mode].apply Math, points.map (pt) -> pt[axis]

  # Returns the top-most coordinate of the geometry shape.
  #
  # Returns a {Number}.
  top: -> pointsBounds @points(), 'min', 'y'

  # Returns the bottom-most coordinate of the geometry shape.
  #
  # Returns a {Number}.
  bottom: -> pointsBounds @points(), 'max', 'y'

  # Returns the left-most coordinate of the geometry shape.
  #
  # Returns a {Number}.
  left: -> pointsBounds @points(), 'min', 'x'

  # Returns the right-most coordinate of the geometry shape.
  #
  # Returns a {Number}.
  right: -> pointsBounds @points(), 'max', 'x'

  # Returns an {Object} containing the bounds of the object.
  #
  # Returns an {Object} with the following properties:
  # :top - The {Number} for the shape upper bound.
  # :bottom - The {Number} for the shape lower bound.
  # :left - The {Number} for the shape left bound.
  # :right - The {Number} for the shape right bound.
  bounds: ->
    top: @top()
    left: @left()
    right: @right()
    bottom: @bottom()

  # Returns a [Rectangle]{agt.geom.Rectangle} corresponding to the bounds
  # of the current geometry.
  #
  # Returns a [Rectangle]{agt.geom.Rectangle}.
  boundingBox: ->
    new agt.geom.Rectangle(
      @left(),
      @top(),
      @right() - @left(),
      @bottom() - @top()
    )

  # Paints the geometry shape in the specified canvas `context` as a line.
  #
  # context - The canvas context into which draw the geometry.
  # color - The {String} color of the stroke.
  stroke: (context, color=agt.COLORS.STROKE) ->
    return unless context?

    context.strokeStyle = color
    @drawPath context
    context.stroke()

  # Paints the geometry shape in the specified canvas `context`
  # as a plain shape.
  #
  # context - The canvas context into which draw the geometry.
  # color - The {String} color of the fill.
  fill: (context, color=agt.COLORS.FILL) ->
    return unless context?

    context.fillStyle = color
    @drawPath context
    context.fill()

  # Draws the current geometry into the passed-in canvas `context`.
  # That method only implements creating the geometry path using
  # canvas methods.
  #
  # context - The canvas context into which draw the geometry.
  drawPath: (context) ->
    points = @points()
    start = points.shift()
    context.beginPath()
    context.moveTo(start.x,start.y)
    context.lineTo(p.x,p.y) for p in points
    context.closePath()
