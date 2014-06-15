
{Point,Intersections,Geometry,Spline,Path} = agt.geom

# Public:
class agt.geom.QuadBezier
  @include mixins.Formattable('QuadBezier')
  @include mixins.Sourcable('agt.geom.QuadBezier', 'vertices', 'bias')
  @include Geometry
  @include Path
  @include Intersections
  @include Spline(2)

  ### Public ###

  constructor: (vertices, bias=20) ->
    @initSpline vertices, bias

  pointInSegment: (t, seg) ->
    pt = new Point()
    pt.x = (seg[0].x * @b1 (t)) +
           (seg[1].x * @b2 (t)) +
           (seg[2].x * @b3 (t))
    pt.y = (seg[0].y * @b1 (t)) +
           (seg[1].y * @b2 (t)) +
           (seg[2].y * @b3 (t))
    pt

  ### Internal ###

  b1: (t) -> ((1 - t) * (1 - t) )

  b2: (t) -> (2 * t * (1 - t))

  b3: (t) -> (t * t)
