
{Point, Geometry, Triangle, Surface, Path, Intersections} = agt.geom

# Public:
class agt.geom.Ellipsis
  properties = ['radius1', 'radius2', 'x', 'y', 'rotation', 'segments']

  @include mixins.Equatable(properties...)
  @include mixins.Formattable(['Ellipsis'].concat(properties)...)
  @include mixins.Parameterizable('ellipsisFrom', {
    radius1: 1
    radius2: 1
    x: 0
    y: 0
    rotation: 0
    segments: 36
  })
  @include mixins.Sourcable(['agt.geom.Ellipsis'].concat(properties)...)
  @include mixins.Cloneable()
  @include mixins.Memoizable
  @include Geometry
  @include Surface
  @include Path
  @include Intersections

  ### Public: Instances Methods ###

  constructor: (r1, r2, x, y, rot, segments) ->
    {@radius1,@radius2,@x,@y,@rotation,@segments} = @ellipsisFrom r1, r2,
                                                                  x, y, rot,
                                                                  segments

  center: -> new Point @x, @y

  left: -> Math.min.apply Math, @xBounds()

  right: -> Math.max.apply Math, @xBounds()

  bottom: -> Math.max.apply Math, @yBounds()

  top: -> Math.min.apply Math, @yBounds()

  # Internal:
  xBounds: ->
    phi = @rotation
    t = Math.atan(-@radius2 * Math.tan(phi) / @radius1)
    [t, t+Math.PI].map (t) =>
      @x + @radius1*Math.cos(t)*Math.cos(phi) -
           @radius2*Math.sin(t)*Math.sin(phi)

  # Internal:
  yBounds: ->
    phi = @rotation
    t = Math.atan(@radius2 * (Math.cos(phi) / Math.sin(phi)) / @radius1)
    [t, t+Math.PI].map (t) =>
      @y + @radius1*Math.cos(t)*Math.sin(phi) +
           @radius2*Math.sin(t)*Math.cos(phi)

  translate: (xOrPt, y) ->
    {x,y} = Point.pointFrom xOrPt, y

    @x += x
    @y += y
    this

  rotate: (rotation) ->
    @rotation += rotation
    this

  scale: (scale) ->
    @radius1 *= scale
    @radius2 *= scale
    this

  points: ->
    @memoFor('points').concat() if @memoized 'points'
    @memoize 'points', (@pathPointAt n / @segments for n in [0..@segments])

  triangles: ->
    return @memoFor 'triangles' if @memoized 'triangles'

    triangles = []
    points = @points()
    center = @center()
    for i in [1..points.length-1]
      triangles.push new Triangle center, points[i-1], points[i]

    @memoize 'triangles', triangles

  closedGeometry: -> true

  pointAtAngle: (angle) ->
    a = angle - @rotation
    ratio = @radius1 / @radius2
    vec = new Point Math.cos(a) * @radius1, Math.sin(a) * @radius1
    vec.x = vec.x / ratio if @radius1 < @radius2
    vec.y = vec.y * ratio if @radius1 > @radius2
    a = vec.angle()
    p = new Point Math.cos(a) * @radius1, Math.sin(a) * @radius2

    @center().add p.rotate(@rotation)

  acreage: -> Math.PI * @radius1 * @radius2

  randomPointInSurface: (random) ->
    unless random?
      random = new random.Random new random.MathRandom

    pt = @pathPointAt random.get()
    center = @center()
    dif = pt.subtract center
    center.add dif.scale Math.sqrt random.random()

  contains: (xOrPt, y) ->
    p = new Point xOrPt, y
    c = @center()
    d = p.subtract c
    a = d.angle()
    p2 = @pointAtAngle a
    c.distance(p2) >= c.distance(p)

  length: -> Math.PI * (3*(@radius1 + @radius2) -
             Math.sqrt((3* @radius1 + @radius2) * (@radius1 + @radius2 *3)))

  pathPointAt: (n) ->
    a = n * Math.PI * 2
    p = new Point Math.cos(a) * @radius1, Math.sin(a) * @radius2

    @center().add p.rotate(@rotation)

  drawPath: (context) ->
    context.save()
    context.translate(@x, @y)
    context.rotate(@rotation)
    context.scale(@radius1, @radius2)
    context.beginPath()
    context.arc(0,0,1,0, Math.PI*2)
    context.closePath()
    context.restore()

  memoizationKey: ->
    "#{@radius1};#{@radius2};#{@x};#{@y};#{@rotation};#{@segments}"
