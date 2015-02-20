{Aliasable, Cloneable, Equatable, Formattable, Sourcable, Parameterizable} = require '../mixins'
{Geometry, Surface, Path, Triangulable, Proxyable, Intersections} = require './mixins'
{Random, MathRandom} = require '../random'
Point = require './point'

# Public: A `Rectangle` geometry is defined with a position, a size
# and a rotation.
#
# ```coffeescript
# rectangle = new Rectangle 20, 20, 80, 40, Math.PI * 0.1
# rectangle = new Rectangle x: 20, y: 20, width: 80, height: 40, rotation: Math.PI * 0.1
# ```
#
# <script>window.exampleKey = 'rectangle'</script>
# <script>drawGeometry(exampleKey, {highlight: true})</script>
#
# ### Included Mixins
#
# - {agt.geom.Geometry}
# - {agt.geom.Intersections}
# - {agt.geom.Path}
# - {agt.geom.Surface}
# - {agt.mixins.Aliasable}
# - [agt.mixins.Cloneable](../../../files/mixins/cloneable.coffee.html)
# - [agt.mixins.Equatable](../../../files/mixins/equatable.coffee.html)
# - [agt.mixins.Formattable](../../../files/mixins/formattable.coffee.html)
# - [agt.mixins.Memoizable](../../../files/mixins/memoizable.coffee.html)
# - [agt.mixins.Parameterizable](../../../files/mixins/parameterizable.coffee.html)
# - [agt.mixins.Sourcable](../../../files/mixins/sourcable.coffee.html)
module.exports =
class Rectangle
  properties = ['x','y','width','height','rotation']

  @extend Aliasable

  @include Cloneable()
  @include Equatable(properties...)
  @include Formattable(['Rectangle'].concat(properties)...)
  @include Sourcable(['agt.geom.Rectangle'].concat(properties)...)
  @include Parameterizable('rectangleFrom', {
    x: NaN
    y: NaN
    width: NaN
    height: NaN
    rotation: NaN
  })
  @include Geometry
  @include Surface
  @include Path
  @include Triangulable
  @include Proxyable
  @include Intersections

  ### Public ###

  # A specific intersection algorithm when confronting two rectangles.
  #
  # <script>drawShapeIntersections(exampleKey, exampleKey)</script>
  #
  # geom1 - The first rectangle.
  # geom2 - The second rectangle.
  # block - The callback {Function} to call for each intersection.
  # data - A {Boolean} of whether to include extra data per intersection.
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

  # Creates a new `Rectangle` instance.
  #
  # x - The x coordinate {Number} of the rectangle or a rectangle-like {Object}.
  # y - The y coordinate {Number} of the rectangle.
  # width - The width {Number} of the rectangle.
  # height - The height {Number} of the rectangle.
  # rotation - The rotation {Number} of the rectangle.
  constructor: (x, y, width, height, rotation) ->
    args = @defaultToZero @rectangleFrom.apply this, arguments
    {@x,@y,@width,@height,@rotation} = args

  # Returns the coordinates of the rectangle's corners in an {Array}.
  #
  # <script>drawGeometryPoints(exampleKey, 'corners')</script>
  #
  # Returns an {Array}.
  corners: -> [@topLeft(), @topRight(), @bottomRight(), @bottomLeft()]

  # Returns the coordinates of the top left corner of the rectangle.
  #
  # <script>drawGeometryPoints(exampleKey, 'topLeft')</script>
  #
  # Returns a [Point]{Point}.
  topLeft: -> new Point(@x, @y)

  # Returns the coordinates of the top right corner of the rectangle.
  #
  # <script>drawGeometryPoints(exampleKey, 'topRight')</script>
  #
  # Returns a [Point]{Point}.
  topRight: -> @topLeft().add(@topEdge())

  # Returns the coordinates of the bottom left corner of the rectangle.
  #
  # <script>drawGeometryPoints(exampleKey, 'bottomLeft')</script>
  #
  # Returns a [Point]{Point}.
  bottomLeft: -> @topLeft().add(@leftEdge())

  # Returns the coordinates of the bottom right corner of the rectangle.
  #
  # <script>drawGeometryPoints(exampleKey, 'bottomRight')</script>
  #
  # Returns a [Point]{Point}.
  bottomRight: -> @topLeft().add(@topEdge()).add(@leftEdge())

  # Returns the coordinates of the center of the rectangle.
  #
  # <script>drawGeometry(exampleKey, {center: true})</script>
  #
  # Returns a [Point]{Point}
  center: -> @topLeft().add(@diagonal().scale(0.5))

  # Returns the coordinates of the center of the upper edge of the rectangle.
  #
  # <script>drawGeometryPoints(exampleKey, 'topEdgeCenter')</script>
  #
  # Returns a [Point]{Point}.
  topEdgeCenter: -> @topLeft().add(@topEdge().scale(0.5))

  # Returns the coordinates of the center of the bottom edge of the rectangle.
  #
  # <script>drawGeometryPoints(exampleKey, 'bottomEdgeCenter')</script>
  #
  # Returns a [Point]{Point}.
  bottomEdgeCenter: -> @bottomLeft().add(@topEdge().scale(0.5))

  # Returns the coordinates of the center of the left edge of the rectangle.
  #
  # <script>drawGeometryPoints(exampleKey, 'leftEdgeCenter')</script>
  #
  # Returns a [Point]{Point}.
  leftEdgeCenter: -> @topLeft().add(@leftEdge().scale(0.5))

  # Returns the coordinates of the center of the right edge of the rectangle.
  #
  # <script>drawGeometryPoints(exampleKey, 'rightEdgeCenter')</script>
  #
  # Returns a [Point]{Point}.
  rightEdgeCenter: -> @topRight().add(@leftEdge().scale(0.5))

  # Returns an array containing all the rectangle's edges vectors.
  #
  # Returns an {Array}.
  edges: -> [@topEdge(), @topRight(), @bottomRight(), @bottomLeft()]

  # Returns the rectangle's top edge vector.
  #
  # <script>drawGeometryEdge(exampleKey, 'topLeft', 'topEdge')</script>
  #
  # Returns a [Point]{Point}.
  topEdge: ->
    if @rotation is 0
      new Point @width, 0
    else
      new Point @width * Math.cos(@rotation),
                         @width * Math.sin(@rotation)

  # Returns the rectangle's left edge vector.
  #
  # <script>drawGeometryEdge(exampleKey, 'topLeft', 'leftEdge')</script>
  #
  # Returns a [Point]{Point}.
  leftEdge: ->
    if @rotation is 0
      new Point 0, @height
    else
      new Point @height * Math.cos(@rotation + Math.PI / 2),
                         @height * Math.sin(@rotation + Math.PI / 2)

  # Returns the rectangle's bottom edge vector.
  #
  # <script>drawGeometryEdge(exampleKey, 'bottomLeft', 'bottomEdge')</script>
  #
  # Returns a [Point]{Point}.
  bottomEdge: -> @topEdge()

  # Returns the rectangle's right edge vector.
  #
  # <script>drawGeometryEdge(exampleKey, 'topRight', 'rightEdge')</script>
  #
  # Returns a [Point]{Point}.
  rightEdge: -> @leftEdge()

  # Returns the rectangle's diagonal vector.
  #
  # <script>drawGeometryEdge(exampleKey, 'topLeft', 'diagonal')</script>
  #
  # Returns a [Point]{Point}.
  diagonal: -> @leftEdge().add(@topEdge())

  # Returns the top-most coordinate of the rectangle shape.
  #
  # <script>drawGeometryBound(exampleKey, 'top')</script>
  #
  # Returns a {Number}.
  top: -> Math.min @y, @topRight().y, @bottomRight().y, @bottomLeft().y

  # Returns the bottom-most coordinate of the rectangle shape.
  #
  # <script>drawGeometryBound(exampleKey, 'bottom')</script>
  #
  # Returns a {Number}.
  bottom: -> Math.max @y, @topRight().y, @bottomRight().y, @bottomLeft().y

  # Returns the left-most coordinate of the rectangle shape.
  #
  # <script>drawGeometryBound(exampleKey, 'left')</script>
  #
  # Returns a {Number}.
  left: -> Math.min @x, @topRight().x, @bottomRight().x, @bottomLeft().x

  # Returns the right-most coordinate of the rectangle shape.
  #
  # <script>drawGeometryBound(exampleKey, 'right')</script>
  #
  # Returns a {Number}.
  right: -> Math.max @x, @topRight().x, @bottomRight().x, @bottomLeft().x

  # Sets the position of the rectangle using its center as reference.
  #
  # <script>drawTransform(exampleKey, {type: 'setCenter', args: [100, 50], width: 150})</script>
  #
  # x - A {Number} for the x coordinate or a point-like {Object}.
  # y - A {Number} for the y coordinate if the first argument
  #     was also a number.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  setCenter: (x, y) ->
    pt = Point.pointFrom(x, y).subtract(@center())

    @x += pt.x
    @y += pt.y
    this

  # Adds the passed-in [Point]{Point} to the position
  # of this rectangle.
  #
  # <script>drawTransform(exampleKey, {type: 'translate', args: [50, 0], width: 150})</script>
  #
  # x - A {Number} for the x coordinate or a point-like {Object}.
  # y - A {Number} for the y coordinate if the first argument
  #     was also a number.
  #
  # Returns this {Rectangle}.
  translate: (x, y) ->
    pt = Point.pointFrom(x, y)

    @x += pt.x
    @y += pt.y
    this

  # Adds the passed-in rotation to the current rectangle rotation.
  #
  # <script>drawTransform(exampleKey, {type: 'rotate', args: [-Math.PI/ 4]})</script>
  #
  # **Note:** This method is also aliased as `rotateAroundCenter`.
  #
  # rotation - The rotation {Number}.
  #
  # Returns this {Rectangle}.
  rotate: (rotation) ->
    {@x,@y} = @topLeft().rotateAround(@center(), rotation)
    @rotation += rotation
    this

  @alias 'rotate', 'rotateAroundCenter'

  # Scales the rectangle by multiplying its width and height by the passed-in
  # scale factor. The scaling is performed from the center of the rectangle,
  # which imply changing the rectangle position.
  # You can use the `width` and `height` property to change the size of the
  # rectangle without affecting the position.
  #
  # <script>drawTransform(exampleKey, {type: 'scale', args: [0.6]})</script>
  #
  # scale - The scale {Number} to apply to the rectangle.
  #
  # Returns this {Rectangle}.
  scale: (scale) ->
    center = @center()
    @width *= scale
    @height *= scale
    @setCenter center
    this

  @alias 'scale', 'scaleAroundCenter'

  # Inflates the rectangle around its center by the amount of the arguments.
  #
  # <script>drawTransform(exampleKey, {type: 'inflateAroundCenter', args: [10, 10]})</script>
  #
  # x - A {Number} for the width or a point-like {Object}.
  # y - A {Number} for the height if the first argument
  #     was also a number.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflateAroundCenter: (x, y) ->
    center = @center()
    @inflate x, y
    @setCenter center
    this

  # Inflates the rectangle from its origin by the amount of the arguments.
  #
  # <script>drawTransform(exampleKey, {type: 'inflate', args: [10, 10]})</script>
  #
  # x - A {Number} for the width or a point-like {Object}.
  # y - A {Number} for the height if the first argument
  #     was also a number.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflate: (x, y) ->
    pt = Point.pointFrom x, y
    @width += pt.x
    @height += pt.y
    this

  # Inflates the rectangle width to the left by the passed-in value.
  #
  # <script>drawTransform(exampleKey, {type: 'inflateLeft', args: [10]})</script>
  #
  # inflate - a {Number} for the width inflation.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflateLeft: (inflate) ->
    @width += inflate
    offset = @topEdge().normalize(-inflate)
    {@x,@y} = @topLeft().add(offset)
    this

  # Inflates the rectangle width to the right by the passed-in value.
  #
  # <script>drawTransform(exampleKey, {type: 'inflateRight', args: [10]})</script>
  #
  # inflate - A {Number} for width inflation.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflateRight: (inflate) ->
    @width += inflate
    this

  # Inflates the rectangle height to the top by the passed-in value.
  #
  # <script>drawTransform(exampleKey, {type: 'inflateTop', args: [10]})</script>
  #
  # x - A {Number} for the height inflation.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflateTop: (inflate) ->
    @height += inflate
    offset = @leftEdge().normalize(-inflate)
    {@x,@y} = @topLeft().add(offset)
    this

  # Inflates the rectangle height to the bottom by the passed-in value.
  #
  # <script>drawTransform(exampleKey, {type: 'inflateBottom', args: [10]})</script>
  #
  # x - A {Number} for the height inflation.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflateBottom: (inflate) ->
    @height += inflate
    this

  # Inflates the rectangle to the top left by the amount of the arguments.
  #
  # <script>drawTransform(exampleKey, {type: 'inflateTopLeft', args: [10, 10]})</script>
  #
  # x - A {Number} for the width or a point-like {Object}.
  # y - A {Number} for the height if the first argument
  #     was also a number.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflateTopLeft: (x, y) ->
    pt = Point.pointFrom x, y
    @inflateLeft pt.x
    @inflateTop pt.y
    this

  # Inflates the rectangle to the top right by the amount of the arguments.
  #
  # <script>drawTransform(exampleKey, {type: 'inflateTopRight', args: [10, 10]})</script>
  #
  # x - A {Number} for the width or a point-like {Object}.
  # y - A {Number} for the height if the first argument
  #     was also a number.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflateTopRight: (x, y) ->
    pt = Point.pointFrom x, y
    @inflateRight pt.x
    @inflateTop pt.y
    this

  # Inflates the rectangle to the bottom left by the amount of the arguments.
  #
  # <script>drawTransform(exampleKey, {type: 'inflateBottomLeft', args: [10, 10]})</script>
  #
  # x - A {Number} for the width or a point-like {Object}.
  # y - A {Number} for the height if the first argument
  #     was also a number.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflateBottomLeft: (x, y) ->
    pt = Point.pointFrom x, y
    @inflateLeft pt.x
    @inflateBottom pt.y
    this

  # Inflates the rectangle to the bottom right by the amount of the arguments.
  #
  # <script>drawTransform(exampleKey, {type: 'inflateBottomRight', args: [10, 10]})</script>
  #
  # x - A {Number} for the width or a point-like {Object}.
  # y - A {Number} for the height if the first argument
  #     was also a number.
  #
  # Returns this [Rectangle]{agt.geom.Rectangle}.
  inflateBottomRight: (x, y) -> @inflate x, y

  # Always returns `true`.
  #
  # Returns a {Boolean}.
  closedGeometry: -> true

  # Returns the rectangle points.
  #
  # <script>drawGeometryPoints(exampleKey, 'points')</script>
  #
  # Returns an {Array}.
  points: ->
    [@topLeft(), @topRight(), @bottomRight(), @bottomLeft(), @topLeft()]

  # Returns the [Point]{Point} on the perimeter of the rectangle
  # at the given `angle`.
  #
  # angle - The angle {Number}.
  #
  # <script>drawGeometry(exampleKey, {angle: true})</script>
  #
  # Returns a [Point]{Point}.
  pointAtAngle: (angle) ->
    center = @center()
    vec = center.add Math.cos(angle)*10000,
                     Math.sin(angle)*10000
    @intersections(points: -> [center, vec])?[0]

  # Returns the surface {Number} of this rectangle.
  #
  # Returns a {Number}.
  acreage: -> @width * @height

  # Returns `true` when the given point is contained in the rectangle.
  #
  # In the example below all the green points on the screen represents
  # coordinates that are contained in the rectangle.
  #
  # <script>drawGeometry(exampleKey, {contains: true})</script>
  #
  # x - A {Number} for the x coordinate or a point-like {Object}.
  # y - A {Number} for the y coordinate if the first argument
  #     was also a number.
  #
  # Returns a {Boolean}.
  contains: (x, y) ->
    {x,y} = new Point(x, y).rotateAround(@topLeft(), -@rotation)
    (@x <= x <= @x + @width) and (@y <= y <= @y + @height)

  # Returns a randomly generated point within the rectangle perimeter.
  #
  # <script>drawGeometry(exampleKey, {surface: true})</script>
  #
  # random - An optional [Random]{agt.random.Random} instance to use instead
  #          of the default `Math` random method.
  #
  # Returns a [Point]{Point}.
  randomPointInSurface: (random) ->
    unless random?
      random = new Random new MathRandom
    @topLeft()
      .add(@topEdge().scale random.get())
      .add(@leftEdge().scale random.get())

  # Returns the length {Number} of the rectangle perimeter.
  #
  # Returns a {Number}.
  length: -> @width * 2 + @height * 2

  # Returns a [Point]{Point} on the rectangle perimeter using
  # a {Number} between `0` and `1`.
  #
  # <script>drawGeometry(exampleKey, {paths: [0, 1/3, 2/3]})</script>
  #
  # n - A {Number} between `0` and `1`a {Number} between `0` and `1`.
  # pathBasedOnLength - A {Boolean} of whether the position on the path
  #                     consider the length of the path segments or not.
  #                     When true, each segment will only weight as much
  #                     as their own length.
  #                     When false, every segment have the same weight,
  #                     resulting in a difference in speed when animating
  #                     an object along a path.
  #
  # Returns a [Point]{Point}.
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

  # Returns the angle of the rectangle perimeter at the path position {Number}.
  #
  # <script>drawGeometry(exampleKey, {paths: [0, 1/3, 2/3]})</script>
  #
  # n - A {Number} between `0` and `1`a {Number} between `0` and `1`.
  # pathBasedOnLength - A {Boolean} of whether the position on the path
  #                     consider the length of the path segments or not.
  #                     When true, each segment will only weight as much
  #                     as their own length.
  #                     When false, every segment have the same weight,
  #                     resulting in a difference in speed when animating
  #                     an object along a path.
  #
  # Returns a {Number}.
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

  # Internal: Calculates the proportions of each step of the rectangle path.
  #
  # Returns an {Array}.
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

  # {Delegates to: agt.geom.Geometry.drawPath}
  drawPath: (context) ->
    context.beginPath()
    context.moveTo(@x, @y)
    context.lineTo(@topRight().x, @topRight().y)
    context.lineTo(@bottomRight().x, @bottomRight().y)
    context.lineTo(@bottomLeft().x, @bottomLeft().y)
    context.lineTo(@x, @y)
    context.closePath()

  # Pastes the values of the passed-in rectangle into this one.
  #
  # x - The x coordinate {Number} of the rectangle or a rectangle-like {Object}.
  # y - The y coordinate {Number} of the rectangle.
  # width - The width {Number} of the rectangle.
  # height - The height {Number} of the rectangle.
  # rotation - The rotation {Number} of the rectangle.
  paste: (x, y, width, height, rotation) ->
    values = @rectangleFrom x, y, width, height, rotation
    @[k] = parseFloat v for k,v of values when Math.isFloat v

  # Internal: Resets all invalid number in the passed-in array to `0`.
  #
  # values - An {Array} containing numeric values.
  #
  # Returns an {Array}.
  defaultToZero: (values) ->
    values[k] = 0 for k,v of values when not Math.isFloat v
    values

  @proxy 'pathOrientationAt', as: 'Angle'
  @proxy 'points', 'corners', 'edges', as: 'PointList'
  @proxy 'topLeft', 'topRight', 'bottomLeft', 'bottomRight', 'center', 'topEdgeCenter', 'bottomEdgeCenter', 'leftEdgeCenter', 'rightEdgeCenter', 'topEdge', 'leftEdge', 'rightEdge', 'bottomEdge', 'diagonal', 'pathPointAt', as: 'Point'
