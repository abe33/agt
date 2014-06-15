
{Point,Intersections,Geometry,Spline,Path} = agt.geom

# Public:
class agt.geom.QuintBezier
  @include mixins.Formattable('QuintBezier')
  @include mixins.Sourcable('agt.geom.QuintBezier', 'vertices', 'bias')
  @include Geometry
  @include Path
  @include Intersections
  @include Spline(4)

  ### Public ###

  constructor: (vertices, bias=20) ->
    @initSpline vertices, bias

  pointInSegment: (t, seg) ->
    pt = new Point()
    pt.x = (seg[0].x * @b1 (t)) +
           (seg[1].x * @b2 (t)) +
           (seg[2].x * @b3 (t)) +
           (seg[3].x * @b4 (t)) +
           (seg[4].x * @b5 (t))
    pt.y = (seg[0].y * @b1 (t)) +
           (seg[1].y * @b2 (t)) +
           (seg[2].y * @b3 (t)) +
           (seg[3].y * @b4 (t)) +
           (seg[4].y * @b5 (t))
    pt

  ### Internal ###

  b1: (t) -> ((1 - t) * (1 - t) * (1 - t) * (1 - t))

  b2: (t) -> (4 * t * (1 - t) * (1 - t) * (1 - t))

  b3: (t) -> (6 * t * t * (1 - t) * (1 - t))

  b4: (t) -> (4 * t * t * t * (1 - t))

  b5: (t) -> (t * t * t * t)
