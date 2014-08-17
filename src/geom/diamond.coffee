namespace('agt.geom')

# Public:
class agt.geom.Diamond
  properties = ['topLength', 'rightLength', 'bottomLength', 'leftLength', 'x', 'y', 'rotation']

  @include agt.mixins.Formattable(['Diamond'].concat(properties)...)
  @include agt.mixins.Parameterizable('diamondFrom', {
    topLength: 1
    rightLength: 1
    bottomLength: 1
    leftLength: 1
    x: 0
    y: 0
    rotation: 0
  })
  @include agt.mixins.Sourcable(['agt.geom.Diamond'].concat properties)
  @include agt.mixins.Equatable(properties...)
  @include agt.mixins.Cloneable()
  @include agt.mixins.Memoizable
  @include agt.geom.Geometry
  @include agt.geom.Surface
  @include agt.geom.Path
  @include agt.geom.Intersections

  ### Public ###

  constructor: (topLength, rightLength, bottomLength, leftLength, x, y, rotation) ->
    args = @diamondFrom topLength, rightLength, bottomLength, leftLength, x, y, rotation
    {@topLength, @rightLength, @bottomLength, @leftLength, @x, @y, @rotation} = args

  center: -> new agt.geom.Point(@x, @y)

  topAxis: -> new agt.geom.Point(0,-@topLength).rotate(@rotation)

  bottomAxis: -> new agt.geom.Point(0,@bottomLength).rotate(@rotation)

  leftAxis: -> new agt.geom.Point(-@leftLength,0).rotate(@rotation)

  rightAxis: -> new agt.geom.Point(@rightLength,0).rotate(@rotation)

  corners: ->
    [
      @topCorner()
      @rightCorner()
      @bottomCorner()
      @leftCorner()
    ]

  topCorner: -> @center().add(@topAxis())

  bottomCorner: -> @center().add(@bottomAxis())

  leftCorner: -> @center().add(@leftAxis())

  rightCorner: -> @center().add(@rightAxis())

  edges: ->
    [
      @topLeftEdge()
      @topRightEdge()
      @bottomRightEdge()
      @bottomLeftEdge()
    ]

  topLeftEdge: -> @topCorner().subtract(@leftCorner())

  topRightEdge: -> @rightCorner().subtract(@topCorner())

  bottomLeftEdge: -> @leftCorner().subtract(@bottomCorner())

  bottomRightEdge: -> @bottomCorner().subtract(@rightCorner())

  quadrants: ->
    [
      @topLeftQuadrant()
      @topRightQuadrant()
      @bottomRightQuadrant()
      @bottomLeftQuadrant()
    ]

  topLeftQuadrant: ->
    k = 'topLeftQuadrant'
    return @memoFor k if @memoized k
    @memoize k, new agt.geom.Triangle(@center(), @topCorner(), @leftCorner())

  topRightQuadrant: ->
    k = 'topRightQuadrant'
    return @memoFor k if @memoized k
    @memoize k, new agt.geom.Triangle(@center(), @topCorner(), @rightCorner())

  bottomLeftQuadrant: ->
    k = 'bottomLeftQuadrant'
    return @memoFor k if @memoized k
    @memoize k, new agt.geom.Triangle(@center(), @bottomCorner(), @leftCorner())

  bottomRightQuadrant: ->
    k = 'bottomRightQuadrant'
    return @memoFor k if @memoized k
    @memoize k, new agt.geom.Triangle(@center(), @bottomCorner(), @rightCorner())

  top: -> Math.min @topCorner().y,
                   @bottomCorner().y,
                   @leftCorner().y,
                   @rightCorner().y,

  bottom: -> Math.max @topCorner().y,
                      @bottomCorner().y,
                      @leftCorner().y,
                      @rightCorner().y,

  left: -> Math.min @topCorner().x,
                    @bottomCorner().x,
                    @leftCorner().x,
                    @rightCorner().x,

  right: -> Math.max @topCorner().x,
                     @bottomCorner().x,
                     @leftCorner().x,
                     @rightCorner().x,

  translate: (xOrPt, y) ->
    {x,y} = agt.geom.Point.pointFrom xOrPt, y

    @x += x
    @y += y
    this

  rotate: (rotation) ->
    @rotation += rotation
    this

  scale: (scale) ->
    @topLength *= scale
    @bottomLength *= scale
    @rightLength *= scale
    @leftLength *= scale
    this

  points: ->
    [t = @topCorner(), @rightCorner(), @bottomCorner(), @leftCorner(), t]

  triangles: -> @quadrants()

  closedGeometry: -> true

  pointAtAngle: (angle) ->
    center = @center()
    vec = center.add Math.cos(angle)*10000,
                     Math.sin(angle)*10000
    @intersections(points: -> [center, vec])?[0]

  acreage: ->
    @topLeftQuadrant().acreage() +
    @topRightQuadrant().acreage() +
    @bottomLeftQuadrant().acreage() +
    @bottomRightQuadrant().acreage()

  contains: (x,y) ->
    @center().equals(x,y) or
    @topLeftQuadrant().contains(x,y) or
    @topRightQuadrant().contains(x,y) or
    @bottomLeftQuadrant().contains(x,y) or
    @bottomRightQuadrant().contains(x,y)

  randomPointInSurface: (random) ->
    l = @acreage()
    q1 = @topLeftQuadrant()
    q2 = @topRightQuadrant()
    q3 = @bottomRightQuadrant()
    q4 = @bottomLeftQuadrant()

    a1 = q1.acreage()
    a2 = q2.acreage()
    a3 = q3.acreage()
    a4 = q4.acreage()
    a = a1 + a2 + a3 + a4

    l1 = a1 / a
    l2 = a2 / a
    l3 = a3 / a
    l4 = a4 / a

    n = random.get()

    if n < l1
      q1.randomPointInSurface random
    else if n < l1 + l2
      q2.randomPointInSurface random
    else if n < l1 + l2 + l3
      q3.randomPointInSurface random
    else
      q4.randomPointInSurface random

  length: ->
    @topRightEdge().length() +
    @topLeftEdge().length() +
    @bottomRightEdge().length() +
    @bottomLeftEdge().length()

  pathPointAt: (n, pathBasedOnLength=true) ->
    [p1,p2,p3] = @pathSteps pathBasedOnLength

    if n < p1
      @topCorner().add @topRightEdge().scale Math.map n, 0, p1, 0, 1
    else if n < p2
      @rightCorner().add @bottomRightEdge().scale Math.map n, p1, p2, 0, 1
    else if n < p3
      @bottomCorner().add @bottomLeftEdge().scale Math.map n, p2, p3, 0, 1
    else
      @leftCorner().add @topLeftEdge().scale Math.map n, p3, 1, 0, 1

  pathOrientationAt: (n, pathBasedOnLength=true) ->
    [p1,p2,p3] = @pathSteps pathBasedOnLength

    if n < p1
      p = @topRightEdge()
    else if n < p2
      p = @bottomRightEdge()
    else if n < p3
      p = @bottomLeftEdge().scale -1
    else
      p = @topLeftEdge().scale -1

    p.angle()

  pathSteps: (pathBasedOnLength=true) ->
    if pathBasedOnLength
      l = @length()
      p1 = @topRightEdge().length() / l
      p2 = p1 + @bottomRightEdge().length() / l
      p3 = p2 + @bottomLeftEdge().length() / l
    else
      p1 = 1 / 4
      p2 = 1 / 2
      p3 = 3 / 4

    [p1, p2, p3]

  memoizationKey: ->
    "#{@x};#{@y};#{@rotation};#{@topLength};#{@bottomLength};#{@leftLength};#{@rightLength};"
