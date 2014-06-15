
{Point,Ellipsis,Geometry,Path,Intersections} = agt.geom

# Public:
class agt.geom.Spiral
  properties = ['radius1', 'radius2', 'twirl', 'x', 'y', 'rotation','segments']

  @include mixins.Equatable.apply(null, properties)
  @include mixins.Formattable.apply(null, ['Spiral'].concat properties)
  @include mixins.Parameterizable('spiralFrom', {
    radius1: 1
    radius2: 1
    twirl: 1
    x: 0
    y: 0
    rotation: 0
    segments: 36
  })
  @include mixins.Sourcable.apply(null, ['agt.geom.Spiral'].concat properties)
  @include mixins.Cloneable()
  @include mixins.Memoizable
  @include Geometry
  @include Path
  @include Intersections

  ### Public ###

  constructor: (r1, r2, twirl, x, y, rot, segments) ->
    {
      @radius1
      @radius2
      @twirl
      @x
      @y
      @rotation
      @segments
    } = @spiralFrom r1, r2, twirl, x, y, rot, segments

  center: -> new Point @x, @y

  ellipsis: ->
    return @memoFor 'ellipsis' if @memoized 'ellipsis'
    @memoize 'ellipsis', new Ellipsis this

  translate: (x,y) ->
    {x,y} = Point.pointFrom x, y
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
    return @memoFor('points').concat() if @memoized 'points'
    points = []
    center = @center()
    ellipsis = @ellipsis()

    for i in [0..@segments]
      p = i / @segments
      points.push @pathPointAt p

    @memoize 'points', points

  pathPointAt: (pos, posBasedOnLength=true) ->
    center = @center()
    ellipsis = @ellipsis()
    PI2 = Math.PI * 2
    angle = @rotation + pos * PI2 * @twirl % PI2
    pt = ellipsis.pointAtAngle(angle)?.subtract(center).scale(pos)
    center.add pt

  fill: ->

  drawPath: (context) ->
    points = @points()
    start = points.shift()
    context.beginPath()
    context.moveTo(start.x,start.y)
    context.lineTo(p.x,p.y) for p in points

  memoizationKey = ->
    "#{@radius1};#{@radius2};#{@twirl};#{@x};#{@y};#{@rotation};#{@segments}"
