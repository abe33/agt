
# Public: Geometry
class agt.geom.Geometry

  # Public: **Abstract** - Returns an {Array} of {agt.geom.Point}s constituting
  # the geometry.
  #
  # Returns an {Array} of {agt.geom.Point}s
  points: ->

  # Public: **Abstract** - Returns a {Boolean} of whether the points forms
  # a closed geometry.
  closedGeometry: -> false

  # Internal: The `pointsBounds` private utility is meant to provide
  # the default bounds computation for a geometry, subclasses should
  # implements their own bounds methods if a faster implementation exist.
  pointsBounds = (points, mode, axis) ->
    Math[mode].apply Math, points.map (pt) -> pt[axis]

  # Public: Returns th
  top: -> pointsBounds @points(), 'min', 'y'

  # Public:
  bottom: -> pointsBounds @points(), 'max', 'y'

  # Public:
  left: -> pointsBounds @points(), 'min', 'x'

  # Publilc:
  right: -> pointsBounds @points(), 'max', 'x'

  # Public:
  bounds: ->
    top: @top()
    left: @left()
    right: @right()
    bottom: @bottom()

  # Public:
  boundingBox: ->
    new agt.geom.Rectangle(
      @left(),
      @top(),
      @right() - @left(),
      @bottom() - @top()
    )

  #### Drawing API

  ##### Geometry::stroke
  #
  stroke: (context, color='#ff0000') ->
    return unless context?

    context.strokeStyle = color
    @drawPath context
    context.stroke()

  ##### Geometry::fill
  #
  fill: (context, color='#ff0000') ->
    return unless context?

    context.fillStyle = color
    @drawPath context
    context.fill()

  ##### Geometry::drawPath
  #
  drawPath: (context) ->
    points = @points()
    start = points.shift()
    context.beginPath()
    context.moveTo(start.x,start.y)
    context.lineTo(p.x,p.y) for p in points
    context.closePath()
