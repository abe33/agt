
{Point,Triangulable,Proxyable,Geometry,Surface,Path,Intersections} = agt.geom

# Public:
class agt.geom.Rectangle
  properties = ['x','y','width','height','rotation']

  @extend mixins.Aliasable

  @include mixins.Equatable.apply(null, properties)
  @include mixins.Formattable.apply(null, ['Rectangle'].concat properties)
  @include mixins.Sourcable.apply(null, ['agt.geom.Rectangle'].concat properties)
  @include mixins.Parameterizable('rectangleFrom', {
      x: NaN
      y: NaN
      width: NaN
      height: NaN
      rotation: NaN
    })
  @include mixins.Cloneable()

  @include Geometry
  @include Surface
  @include Path
  @include Triangulable
  @include Proxyable
  @include Intersections

  ### Public ###

  @eachRectangleRectangleIntersections: (geom1, geom2, block, data=false) ->
    if geom1.equals geom2
      for p in geom1.points()
        return if block.call this, p
    else
      @eachIntersections geom1, geom2, block, data

  # Registers the fast intersections iterators for the Rectangle class
  iterators = Intersections.iterators
  k = 'RectangleRectangle'
  iterators[k] = Rectangle.eachRectangleRectangleIntersections

  constructor: (x, y, width, height, rotation) ->
    args = @defaultToZero @rectangleFrom.apply this, arguments
    {@x,@y,@width,@height,@rotation} = args

  corners: -> [@topLeft(), @topRight(), @bottomRight(), @bottomLeft()]

  topLeft: -> new Point(@x, @y)

  topRight: -> @topLeft().add(@topEdge())

  bottomLeft: -> @topLeft().add(@leftEdge())

  bottomRight: -> @topLeft().add(@topEdge()).add(@leftEdge())

  center: -> @topLeft().add(@diagonal().scale(0.5))

  topEdgeCenter: -> @topLeft().add(@topEdge().scale(0.5))

  bottomEdgeCenter: -> @bottomLeft().add(@topEdge().scale(0.5))

  leftEdgeCenter: -> @topLeft().add(@leftEdge().scale(0.5))

  rightEdgeCenter: -> @topRight().add(@leftEdge().scale(0.5))

  edges: -> [@topEdge(), @topRight(), @bottomRight(), @bottomLeft()]

  topEdge: -> new Point @width * Math.cos(@rotation),
                        @width * Math.sin(@rotation)

  leftEdge: ->
    new Point @height * Math.cos(@rotation + Math.PI / 2),
              @height * Math.sin(@rotation + Math.PI / 2)

  bottomEdge: -> @topEdge()

  rightEdge: -> @leftEdge()

  diagonal: -> @leftEdge().add(@topEdge())

  top: -> Math.min @y, @topRight().y, @bottomRight().y, @bottomLeft().y

  bottom: -> Math.max @y, @topRight().y, @bottomRight().y, @bottomLeft().y

  left: -> Math.min @x, @topRight().x, @bottomRight().x, @bottomLeft().x

  right: -> Math.max @x, @topRight().x, @bottomRight().x, @bottomLeft().x

  setCenter: (xOrPt, y) ->
    pt = Point.pointFrom(xOrPt, y).subtract(@center())

    @x += pt.x
    @y += pt.y
    this

  translate: (xOrPt, y) ->
    pt = Point.pointFrom(xOrPt, y)

    @x += pt.x
    @y += pt.y
    this

  rotate: (rotation) ->
    {@x,@y} = @topLeft().rotateAround(@center(), rotation)
    @rotation += rotation
    this

  @alias 'rotate', 'rotateAroundCenter'

  scale: (scale) ->
    center = @center()
    @width *= scale
    @height *= scale
    @setCenter center
    this

  @alias 'scale', 'scaleAroundCenter'

  inflateAroundCenter: (xOrPt, y) ->
    center = @center()
    @inflate xOrPt, y
    @setCenter center
    this

  inflate: (xOrPt, y) ->
    pt = Point.pointFrom xOrPt, y
    @width += pt.x
    @height += pt.y
    this

  inflateLeft: (inflate) ->
    @width += inflate
    offset = @topEdge().normalize(-inflate)
    {@x,@y} = @topLeft().add(offset)
    this

  inflateRight: (inflate) ->
    @width += inflate
    this

  inflateTop: (inflate) ->
    @height += inflate
    offset = @leftEdge().normalize(-inflate)
    {@x,@y} = @topLeft().add(offset)
    this

  inflateBottom: (inflate) ->
    @height += inflate
    this

  inflateTopLeft: (xOrPt, y) ->
    pt = Point.pointFrom xOrPt, y
    @inflateLeft pt.x
    @inflateTop pt.y
    this

  inflateTopRight: (xOrPt, y) ->
    pt = Point.pointFrom xOrPt, y
    @inflateRight pt.x
    @inflateTop pt.y
    this

  inflateBottomLeft: (xOrPt, y) ->
    pt = Point.pointFrom xOrPt, y
    @inflateLeft pt.x
    @inflateBottom pt.y
    this

  inflateBottomRight: (xOrPt, y) -> @inflate xOrPt, y

  closedGeometry: -> true

  points: ->
    [@topLeft(), @topRight(), @bottomRight(), @bottomLeft(), @topLeft()]

  pointAtAngle: (angle) ->
    center = @center()
    vec = center.add Math.cos(angle)*10000,
                     Math.sin(angle)*10000
    @intersections(points: -> [center, vec])?[0]

  acreage: -> @width * @height

  contains: (xOrPt, y) ->
    {x,y} = new Point(xOrPt, y).rotateAround(@topLeft(), -@rotation)
    (@x <= x <= @x + @width) and (@y <= y <= @y + @height)

  randomPointInSurface: (random) ->
    unless random?
      random = new chancejs.Random new chancejs.MathRandom
    @topLeft()
      .add(@topEdge().scale random.get())
      .add(@leftEdge().scale random.get())

  length: -> @width * 2 + @height * 2

  pathPointAt: (n, pathBasedOnLength=true) ->
    [p1,p2,p3] = @pathSteps pathBasedOnLength

    if n < p1
      @topLeft().add @topEdge().scale Math.map n, 0, p1, 0, 1
    else if n < p2
      @topRight().add @rightEdge().scale Math.map n, p1, p2, 0, 1
    else if n < p3
      @bottomRight().add @bottomEdge().scale Math.map(n, p2, p3, 0, 1) * -1
    else
      @bottomLeft().add @leftEdge().scale Math.map(n, p3, 1, 0, 1) * -1

  pathOrientationAt: (n, pathBasedOnLength=true) ->
    [p1,p2,p3] = @pathSteps pathBasedOnLength

    if n < p1
      p = @topEdge()
    else if n < p2
      p = @rightEdge()
    else if n < p3
      p = @bottomEdge().scale -1
    else
      p = @leftEdge().scale -1

    p.angle()

  pathSteps: (pathBasedOnLength=true) ->
    if pathBasedOnLength
      l = @length()
      p1 = @width / l
      p2 = (@width + @height) / l
      p3 = p1 + p2
    else
      p1 = 1 / 4
      p2 = 1 / 2
      p3 = 3 / 4

    [p1, p2, p3]

  drawPath: (context) ->
    context.beginPath()
    context.moveTo(@x, @y)
    context.lineTo(@topRight().x, @topRight().y)
    context.lineTo(@bottomRight().x, @bottomRight().y)
    context.lineTo(@bottomLeft().x, @bottomLeft().y)
    context.lineTo(@x, @y)
    context.closePath()

  paste: (x, y, width, height, rotation) ->
    values = @rectangleFrom x, y, width, height, rotation
    @[k] = parseFloat v for k,v of values when Math.isFloat v

  defaultToZero: (values) ->
    values[k] = 0 for k,v of values when not Math.isFloat v
    values

  @proxy 'pathOrientationAt', as: 'Angle'
  @proxy 'points', 'corners', 'edges', as: 'PointList'
  @proxy 'topLeft', 'topRight', 'bottomLeft', 'bottomRight', 'center', 'topEdgeCenter', 'bottomEdgeCenter', 'leftEdgeCenter', 'rightEdgeCenter', 'topEdge', 'leftEdge', 'rightEdge', 'bottomEdge', 'diagonal', 'pathPointAt', as: 'Point'
