# Public: Every geometry should have the properties of a path. For closed
# geometries, the path starts and ends at the same point of the geometry
# shape. This point can vary from one geometry to another.
#
# Path properties includes:
#
# - **Length** - A path has a {::length} expressed in pixels.
# - **Positionning** - A path offers to get a [Point]{agt.geom.Point}
#   along the geometry shape based on a {Number} in the range `0..1`.
#   With this point it's also possible to retrieve the orientation
#   of the path as well as the tangent vector at that point.
#
# ```coffeescript
# class DummyPath
#   @include agt.geom.Path
#
#   # Your path implementation
# ```
#
# The default implementation include length and path computations based
# on the distances between the [points]{agt.geom.Geometry::points}
# of the geometry.
#
# If a more accurate or faster implementation exists the path geometries
# generally overwrites the default methods with their implementations (see
# the [Circle]{agt.geom.Circle} or [Rectangle]{agt.geom.Rectangle} classes
# for real word examples).
class agt.geom.Path

  ### Public ###

  # **Abstract** - Returns the length of the path in pixels.
  #
  # Returns a {Number}.
  length: ->
    sum = 0
    points = @points()
    if points.length > 1
      for i in [1..points.length]
        sum += points[i-1].distance(points[i])
    sum

  # Returns the coordinates on the path at the given {Number} position.
  #
  # pos - The {Number} between `0` and `1` at which get the path coordinates.
  # pathBasedOnLength - A {Boolean} of whether the position on the path
  #                     consider the length of the path segments or not.
  #                     With the default implementation, when true, each
  #                     segment will only weight as much as their own length.
  #                     When false, every segment have the same weight,
  #                     resulting in a difference in speed when animating
  #                     an object along a path.
  #
  # Returns a [Point]{agt.geom.Point}.
  pathPointAt: (pos, pathBasedOnLength=true) ->
    pos = 0 if pos < 0
    pos = 1 if pos > 1
    points = @points()

    return points[0] if pos is 0
    return points[points.length - 1] if pos is 1

    if pathBasedOnLength
      @walkPathBasedOnLength pos, points
    else
      @walkPathBasedOnSegments pos, points

  # Returns the orientation on the path at the given {Number} position.
  #
  # pos - The {Number} between `0` and `1` at which get the path coordinates.
  # pathBasedOnLength - A {Boolean} of whether the position on the path
  #                     consider the length of the path segments or not.
  #                     With the default implementation, when true, each
  #                     segment will only weight as much as their own length.
  #                     When false, every segment have the same weight,
  #                     resulting in a difference in speed when animating
  #                     an object along a path.
  #
  # Returns a {Number}.
  pathOrientationAt: (pos, pathBasedOnLength=true) ->
    p1 = @pathPointAt pos - 0.01, pathBasedOnLength
    p2 = @pathPointAt pos + 0.01, pathBasedOnLength
    d = p2.subtract p1

    return d.angle()

  # Returns the tangent vector at the given {Number} position.
  #
  # pos - The {Number} between `0` and `1` at which get the path coordinates.
  # accuracy - A {Number} giving the distance, relatively to the path length,
  #            at which sample path data around the position to approximate
  #            the tangent.
  # pathBasedOnLength - A {Boolean} of whether the position on the path
  #                     consider the length of the path segments or not.
  #                     With the default implementation, when true, each
  #                     segment will only weight as much as their own length.
  #                     When false, every segment have the same weight,
  #                     resulting in a difference in speed when animating
  #                     an object along a path.
  #
  # Returns a [Point]{agt.geom.Point}
  pathTangentAt: (pos, accuracy=1 / 100, pathBasedOnLength=true) ->
    [pathBasedOnLength, accuracy] = [accuracy, 1/100] if typeof accuracy is 'boolean'
    @pathPointAt((pos + accuracy) % 1, pathBasedOnLength)
      .subtract(@pathPointAt((1 + pos - accuracy) % 1), pathBasedOnLength)
      .normalize(1)

  ### Internal ###

  walkPathBasedOnLength: (pos, points) ->
    walked = 0
    length = @length()

    for i in [1..points.length-1]
      p1 = points[i-1]
      p2 = points[i]
      stepLength = p1.distance(p2) / length

      if walked + stepLength > pos
        innerStepPos = Math.map pos, walked, walked + stepLength, 0, 1
        return @pointInSegment innerStepPos, [p1, p2]

      walked += stepLength

  walkPathBasedOnSegments: (pos, points) ->
    segments = points.length - 1
    pos = pos * segments
    segment = Math.floor pos
    segment -= 1 if segment is segments
    @pointInSegment pos - segment, points[segment..segment+1]

  pointInSegment: (pos, segment) ->
    segment[0].add segment[1].subtract(segment[0]).scale(pos)
