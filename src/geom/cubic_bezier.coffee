{Formattable, Sourcable} = require '../mixins'
{Geometry, Path, Intersections, Spline} = require './mixins'
Point = require './point'
# Public:
module.exports =
class CubicBezier
  @include Formattable('CubicBezier')
  @include Sourcable('agt.geom.CubicBezier', 'vertices', 'bias')
  @include Geometry
  @include Path
  @include Intersections
  @include Spline(3)

  ### Public ###

  constructor: (vertices, bias=20) ->
    @initSpline vertices, bias

  pointInSegment: (t, seg) ->
    pt = new Point()
    pt.x = (seg[0].x * @b1 (t)) +
           (seg[1].x * @b2 (t)) +
           (seg[2].x * @b3 (t)) +
           (seg[3].x * @b4 (t))
    pt.y = (seg[0].y * @b1 (t)) +
           (seg[1].y * @b2 (t)) +
           (seg[2].y * @b3 (t)) +
           (seg[3].y * @b4 (t))
    pt

  ### Internal ###

  b1: (t) -> ((1 - t) * (1 - t) * (1 - t))

  b2: (t) -> (3 * t * (1 - t) * (1 - t))

  b3: (t) -> (3 * t * t * (1 - t))

  b4: (t) -> (t * t * t)
