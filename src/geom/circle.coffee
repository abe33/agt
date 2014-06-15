{Point, Triangle, Geometry, Surface, Path, Intersections} = agt.geom

# Public: 
class agt.geom.Circle
  @include mixins.Equatable('x','y','radius')
  @include mixins.Formattable('Circle','x','y','radius')
  @include mixins.Parameterizable('circleFrom', radius: 1, x: 0, y: 0, segments: 36)
  @include mixins.Sourcable('agt.geom.Circle', 'radius', 'x', 'y')
  @include mixins.Cloneable()
  @include mixins.Memoizable
  @include Geometry
  @include Surface
  @include Path
  @include Intersections

  ### Public: Class Methods ###

  @eachIntersections: (geom1, geom2, block, data=false) ->
    [geom1, geom2] = [geom2, geom1] if geom2.classname?() is 'Circle'
    points = geom2.points()
    length = points.length
    output = []

    for i in [0..length-2]
      sv = points[i]
      ev = points[i+1]

      return if geom1.eachLineIntersections sv, ev, block

  @eachCircleCircleIntersections: (geom1, geom2, block, data=false) ->
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

  ### Public: Instances Methods ###

  constructor: (radiusOrCircle, x, y, segments) ->
    {@radius,@x,@y,@segments} = @circleFrom radiusOrCircle, x, y, segments

  center: -> new Point @x, @y

  top: -> @y - @radius

  bottom: -> @y + @radius

  left: -> @x - @radius

  right: -> @x + @radius

  translate: (xOrPt, y) ->
    {x,y} = Point.pointFrom xOrPt, y

    @x += x
    @y += y
    this

  # Circles does not have a rotation, so this method do nothing
  rotate: -> this

  scale: (scale) ->
    @radius *= scale
    this

  points: ->
    step = Math.PI * 2 / @segments
    @pointAtAngle n * step for n in [0..@segments]

  triangles: ->
    return @memoFor 'triangles' if @memoized 'triangles'

    triangles = []
    points = @points()
    center = @center()
    for i in [1..points.length-1]
      triangles.push new Triangle center, points[i-1], points[i]

    @memoize 'triangles', triangles

  closedGeometry: -> true

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

  pointAtAngle: (angle) ->
    new Point @x + Math.cos(angle) * @radius,
              @y + Math.sin(angle) * @radius

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

  memoizationKey: -> "#{@radius};#{@x};#{@y};#{@segments}"
