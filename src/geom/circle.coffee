{Point, Triangle, Geometry, Surface, Path, Intersections} = agt.geom

# Public: A `Circle` object is defined by a radius, a position
# and a rotation.
#
# ```coffeescript
# circle = new Circle 80, 100, 100
# ```
#
# <script>drawGeometry('circle', {highlight: true})</script>
#
# ### Included Mixins
#
# - {agt.geom.Geometry}
# - {agt.geom.Intersections}
# - {agt.geom.Path}
# - {agt.geom.Surface}
# - [agt.mixins.Cloneable](../../../files/mixins/cloneable.coffee.html)
# - [agt.mixins.Equatable](../../../files/mixins/equatable.coffee.html)
# - [agt.mixins.Formattable](../../../files/mixins/formattable.coffee.html)
# - [agt.mixins.Memoizable](../../../files/mixins/memoizable.coffee.html)
# - [agt.mixins.Parameterizable](../../../files/mixins/parameterizable.coffee.html)
# - [agt.mixins.Sourcable](../../../files/mixins/sourcable.coffee.html)
class agt.geom.Circle
  @include mixins.Equatable('x','y','radius','rotation')
  @include mixins.Formattable('Circle','x','y','radius','rotation')
  @include mixins.Parameterizable('circleFrom', radius: 1, x: 0, y: 0, rotation: 0, segments: 36)
  @include mixins.Sourcable('agt.geom.Circle', 'radius', 'x', 'y', 'rotation', 'segments')
  @include mixins.Cloneable()
  @include mixins.Memoizable
  @include Geometry
  @include Surface
  @include Path
  @include Intersections

  # Internal: The general intersections algorithm for circles with non-circle
  # geometries.
  #
  # geom1 - The first [Geometry]{agt.geom.Geometry}.
  # geom2 - The second [Geometry]{agt.geom.Geometry}.
  # block - The iterator {Function} to call with the found intersections.
  @eachIntersections: (geom1, geom2, block) ->
    [geom1, geom2] = [geom2, geom1] if geom2.classname?() is 'Circle'
    points = geom2.points()
    length = points.length
    output = []

    for i in [0..length-2]
      sv = points[i]
      ev = points[i+1]

      return if geom1.eachLineIntersections sv, ev, block

  # Internal: The specific algorithm for circle with circle intersections.
  #
  # geom1 - The first `Circle`.
  # geom2 - The second `Circle`.
  # block - The iterator {Function} to call with the found intersections.
  @eachCircleCircleIntersections: (geom1, geom2, block) ->
    if geom1.equals geom2
      for p in geom1.points()
        return if block.call this, p
    else
      r1 = geom1.radius
      r2 = geom2.radius
      p1 = geom1.center()
      p2 = geom2.center()
      d = p1.distance(p2)
      dv = p2.subtract(p1)
      radii = r1 + r2

      return if d > radii
      return block.call this, p1.add(dv.normalize(r1)) if d is radii

      a = (r1*r1 - r2*r2 + d*d) / (2*d)
      h = Math.sqrt(r1*r1 - a*a)
      hv = new Point h * (p2.y - p1.y) / d,
                     -h * (p2.x - p1.x) / d

      p = p1.add(dv.normalize(a)).add(hv)
      block.call this, p

      p = p1.add(dv.normalize(a)).add(hv.scale(-1))
      block.call this, p

  # Registers the fast intersections iterators for the Circle class
  iterators = Intersections.iterators
  iterators['Circle'] = Circle.eachIntersections
  iterators['CircleCircle'] = Circle.eachCircleCircleIntersections

  ### Public ###

  # Creates a new circle instance.
  #
  # radius - The radius {Number} or a circle-like {Object}.
  # x - The {Number} position of the circle center on the x axis.
  # u - The {Number} position of the circle center on the y axis.
  # rotation - The rotation {Number} of the circle in radians.
  # segments - The {Number} of segments when drawing the circle.
  constructor: (radius, x, y, rotation, segments) ->
    {@radius,@x,@y,@rotation,@segments} = @circleFrom radius, x, y, rotation, segments

  # Returns the center of the circle.
  #
  # <script>drawGeometry('circle', {center: true})</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  center: -> new Point @x, @y

  # Returns the top-most coordinate of the circle shape.
  #
  # <script>drawGeometryBound('circle', 'top')</script>
  #
  # Returns a {Number}.
  top: -> @y - @radius

  # Returns the bottom-most coordinate of the circle shape.
  #
  # <script>drawGeometryBound('circle', 'bottom')</script>
  #
  # Returns a {Number}.
  bottom: -> @y + @radius

  # Returns the left-most coordinate of the circle shape.
  #
  # <script>drawGeometryBound('circle', 'left')</script>
  #
  # Returns a {Number}.
  left: -> @x - @radius

  # Returns the right-most coordinate of the circle shape.
  #
  # <script>drawGeometryBound('circle', 'right')</script>
  #
  # Returns a {Number}.
  right: -> @x + @radius

  # Adds the passed-in [Point]{agt.geom.Point} to the position
  # of this circle.
  #
  # x - A {Number} for the x coordinate or a point-like {Object}.
  # y - A {Number} for the y coordinate if the first argument
  #     was also a number.
  #
  # Returns this {Circle}.
  translate: (x, y) ->
    {x,y} = Point.pointFrom x, y

    @x += x
    @y += y
    this

  # Adds the passed-in rotation to the current circle rotation.
  #
  # rotation - The rotation {Number}.
  #
  # Returns this {Circle}.
  rotate: (rotation) ->
    @rotation += rotation
    this

  # Scales the circle by multiplying its radius by the passed-in `scale`.
  #
  # scale - The scale {Number} to apply to the circle.
  #
  # Returns this {Circle}.
  scale: (scale) ->
    @radius *= scale
    this

  # Returns the circle points as approximated using the current `segments`
  # of the circle.
  #
  # <script>drawGeometryPoints('circle', 'points')</script>
  #
  # Returns an {Array}.
  points: ->
    step = Math.PI * 2 / @segments
    @pointAtAngle(n * step) for n in [0..@segments]

  # Returns the triangles forming the circle as approximated using
  # the current `segments` of the circle.
  #
  # <script>drawGeometry('circle', {triangles: true})</script>
  #
  # Returns an {Array}.
  triangles: ->
    return @memoFor 'triangles' if @memoized 'triangles'

    triangles = []
    points = @points()
    center = @center()
    for i in [1..points.length-1]
      triangles.push new Triangle center, points[i-1], points[i]

    @memoize 'triangles', triangles

  # Always returns `true`.
  #
  # Returns a {Boolean}.
  closedGeometry: -> true

  # Iterates over all intersections between the vector formed by the `a` and `b`
  # [Points]{agt.geom.Point} and the current circle.
  #
  # <script>drawLineIntersections('circle')</script>
  #
  # a - The starting [Points]{agt.geom.Point} of the vector.
  # b - The ending [Points]{agt.geom.Point} of the vector.
  # block - The iterator {Function} to call with the found intersections.
  eachLineIntersections: (a, b, block) ->
    c = @center()

    _a = (b.x - a.x) * (b.x - a.x) +
         (b.y - a.y) * (b.y - a.y)
    _b = 2 * ((b.x - a.x) * (a.x - c.x) +
              (b.y - a.y) * (a.y - c.y))
    cc = c.x * c.x +
         c.y * c.y +
         a.x * a.x +
         a.y * a.y -
         2 * (c.x * a.x + c.y * a.y) - @radius * @radius
    deter = _b * _b - 4 * _a * cc

    if deter > 0
      e = Math.sqrt deter
      u1 = ( - _b + e ) / (2 * _a )
      u2 = ( - _b - e ) / (2 * _a )
      unless ((u1 < 0 || u1 > 1) && (u2 < 0 || u2 > 1))
        if 0 <= u2 and u2 <= 1
          return if block.call this, Point.interpolate a, b, u2

        if 0 <= u1 and u1 <= 1
          return if block.call this, Point.interpolate a, b, u1

  # Returns the [Point]{agt.geom.Point} on the perimeter of the circle
  # at the given `angle`.
  #
  # angle - The angle {Number}.
  #
  # <script>drawGeometry('circle', {angle: true})</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  pointAtAngle: (angle) ->
    new Point @x + Math.cos(@rotation + angle) * @radius,
              @y + Math.sin(@rotation + angle) * @radius


  acreage: -> @radius * @radius * Math.PI

  contains: (xOrPt, y) ->
    pt = Point.pointFrom xOrPt, y, true

    @center().subtract(pt).length() <= @radius

  randomPointInSurface: (random) ->
    unless random?
      random = new random.Random new random.MathRandom

    pt = @pointAtAngle random.random(Math.PI * 2)
    center = @center()
    dif = pt.subtract center
    center.add dif.scale Math.sqrt random.random()

  length: -> @radius * Math.PI * 2

  pathPointAt: (n) -> @pointAtAngle n * Math.PI * 2

  drawPath: (context) ->
    context.beginPath()
    context.arc @x, @y, @radius, 0, Math.PI * 2

  memoizationKey: -> "#{@radius};#{@x};#{@y};#{@rotation};#{@segments}"
