namespace('agt.geom')

# Public:
#
# ### Included Mixins
#
# - {agt.geom.Geometry}
# - {agt.geom.Intersections}
# - {agt.geom.Path}
# - [agt.mixins.Spline](../../../files/geom/mixins/spline.coffee.html)
# - [agt.mixins.Formattable](../../../files/mixins/formattable.coffee.html)
# - [agt.mixins.Memoizable](../../../files/mixins/memoizable.coffee.html)
# - [agt.mixins.Sourcable](../../../files/mixins/sourcable.coffee.html)
class agt.geom.QuadBezier
  @include agt.mixins.Formattable('QuadBezier')
  @include agt.mixins.Sourcable('agt.geom.QuadBezier', 'vertices', 'bias')
  @include agt.geom.Geometry
  @include agt.geom.Path
  @include agt.geom.Intersections
  @include agt.geom.Spline(2)

  ### Public ###

  constructor: (vertices, bias=20) ->
    @initSpline vertices, bias

  pointInSegment: (t, seg) ->
    pt = new agt.geom.Point()
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
