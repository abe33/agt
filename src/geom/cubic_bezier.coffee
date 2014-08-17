namespace('agt.geom')

# Public:
class agt.geom.CubicBezier
  @include agt.mixins.Formattable('CubicBezier')
  @include agt.mixins.Sourcable('agt.geom.CubicBezier', 'vertices', 'bias')
  @include agt.geom.Geometry
  @include agt.geom.Path
  @include agt.geom.Intersections
  @include agt.geom.Spline(3)

  ### Public ###

  constructor: (vertices, bias=20) ->
    @initSpline vertices, bias

  pointInSegment: (t, seg) ->
    pt = new agt.geom.Point()
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
