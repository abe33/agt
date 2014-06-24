
{Point,Path,Surface,Geometry,Intersections} = agt.geom

# Public:
#
# <script>drawGeometry('triangle', {highlight: true})</script>
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
# - [agt.mixins.Sourcable](../../../files/mixins/sourcable.coffee.html)
class agt.geom.Triangle
  @include mixins.Equatable('a','b','c')
  @include mixins.Formattable('Triangle','a','b','c')
  @include mixins.Sourcable('agt.geom.Triangle','a','b','c')
  @include mixins.Cloneable()
  @include mixins.Memoizable
  @include Geometry
  @include Surface
  @include Path
  @include Intersections

  ### Public ###

  # Returns a triangle-like {Object} using the given arguments.
  #
  # a - Either a [Point]{agt.geom.Point} or a triangle-like {Object}.
  # b - A [Point]{agt.geom.Point} when the first parameter is also a point.
  # c - A [Point]{agt.geom.Point} when the first parameter is also a point.
  #
  # Returns an {Object} with the following properties:
  #   :a - A [Point]{agt.geom.Point} for the first vertex of the triangle.
  #   :b - A [Point]{agt.geom.Point} for the second vertex of the triangle.
  #   :c - A [Point]{agt.geom.Point} for the mast vertex of the triangle.
  @triangleFrom: (a, b, c) ->
    {a,b,c} = a if a? and typeof a is 'object' and not Point.isPoint a

    @invalidPoint 'a', a unless Point.isPoint a
    @invalidPoint 'b', b unless Point.isPoint b
    @invalidPoint 'c', c unless Point.isPoint c

    {
      a: new Point(a)
      b: new Point(b)
      c: new Point(c)
    }

  # Creates a new `Triangle` instance.
  #
  # a - Either a [Point]{agt.geom.Point} or a triangle-like {Object}.
  # b - A [Point]{agt.geom.Point} when the first parameter is also a point.
  # c - A [Point]{agt.geom.Point} when the first parameter is also a point.
  constructor: (a, b, c) ->
    {@a,@b,@c} = @triangleFrom a, b, c

  # Returns the center of the triangle.
  #
  # <script>drawGeometry('triangle', {center: true})</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  center: -> new Point (@a.x + @b.x + @c.x) / 3,
                       (@a.y + @b.y + @c.y) / 3

  # Returns the center of the `ab` edge of the triangle.
  #
  # <script>drawGeometryPoints('triangle', 'abCenter')</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  abCenter: -> @a.add @ab().scale(0.5)

  # Returns the center of the `ac` edge of the triangle.
  #
  # <script>drawGeometryPoints('triangle', 'acCenter')</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  acCenter: -> @a.add @ac().scale(0.5)

  # Returns the center of the `bc` edge of the triangle.
  #
  # <script>drawGeometryPoints('triangle', 'bcCenter')</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  bcCenter: -> @b.add @bc().scale(0.5)

  # Returns an {Array} with the triangle's edges vectors.
  #
  # Returns an {Array}.
  edges: -> [@ab(), @bc(), @ca()]

  # Returns the triangle's `ab` edge vector.
  #
  # <script>drawGeometryEdge('triangle', 'a', 'ab')</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  ab: -> @b.subtract @a

  # Returns the triangle's `ab` edge vector.
  #
  # <script>drawGeometryEdge('triangle', 'a', 'ac')</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  ac: -> @c.subtract @a

  # Returns the triangle's `ba` edge vector.
  #
  # <script>drawGeometryEdge('triangle', 'b', 'ba')</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  ba: -> @a.subtract @b

  # Returns the triangle's `bc` edge vector.
  #
  # <script>drawGeometryEdge('triangle', 'b', 'bc')</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  bc: -> @c.subtract @b

  # Returns the triangle's `ca` edge vector.
  #
  # <script>drawGeometryEdge('triangle', 'c', 'ca')</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  ca: -> @a.subtract @c

  # Returns the triangle's `cb` edge vector.
  #
  # <script>drawGeometryEdge('triangle', 'c', 'cb')</script>
  #
  # Returns a [Point]{agt.geom.Point}.
  cb: -> @b.subtract @c

  # Returns the angle formed by the {::ba} and {::bc} vectors.
  #
  # Returns a {Number}.
  abc: -> @ba().angleWith @bc()

  # Returns the angle formed by the {::ab} and {::ac} vectors.
  #
  # Returns a {Number}.
  bac: -> @ab().angleWith @ac()

  # Returns the angle formed by the {::ca} and {::cb} vectors.
  #
  # Returns a {Number}.
  acb: -> @ca().angleWith @cb()

  # Returns the top-most coordinate of the triangle shape.
  #
  # <script>drawGeometryBound('triangle', 'top')</script>
  #
  # Returns a {Number}.
  top: -> Math.min @a.y, @b.y, @c.y

  # Returns the bottom-most coordinate of the triangle shape.
  #
  # <script>drawGeometryBound('triangle', 'bottom')</script>
  #
  # Returns a {Number}.
  bottom: -> Math.max @a.y, @b.y, @c.y

  # Returns the left-most coordinate of the triangle shape.
  #
  # <script>drawGeometryBound('triangle', 'left')</script>
  #
  # Returns a {Number}.
  left: -> Math.min @a.x, @b.x, @c.x

  # Returns the right-most coordinate of the triangle shape.
  #
  # <script>drawGeometryBound('triangle', 'right')</script>
  #
  # Returns a {Number}.
  right: -> Math.max @a.x, @b.x, @c.x

  # Returns `true` if the triangle's edge have the same length.
  #
  # Returns a {Boolean}.
  equilateral: ->
    Math.deltaBelowRatio(@ab().length(), @bc().length()) and
    Math.deltaBelowRatio(@ab().length(), @ac().length())

  # Returns `true` if two edges of the triangle have the same length.
  #
  # Returns a {Boolean}.
  isosceles: ->
    Math.deltaBelowRatio(@ab().length(), @bc().length()) or
    Math.deltaBelowRatio(@ab().length(), @ac().length()) or
    Math.deltaBelowRatio(@bc().length(), @ac().length())

  # Returns `true` if one angle of the triangle has a value of `Math.PI / 2`
  # radians (90 degrees).
  #
  # Returns a {Boolean}.
  rectangle: ->
    sqr = Math.PI / 2
    Math.deltaBelowRatio(Math.abs(@abc()), sqr) or
    Math.deltaBelowRatio(Math.abs(@bac()), sqr) or
    Math.deltaBelowRatio(Math.abs(@acb()), sqr)


  translate: (x,y) ->
    pt = Point.pointFrom x,y
    @a.x += pt.x; @a.y += pt.y
    @b.x += pt.x; @b.y += pt.y
    @c.x += pt.x; @c.y += pt.y
    this

  rotate: (rotation) ->
    center = @center()
    @a = @a.rotateAround center, rotation
    @b = @b.rotateAround center, rotation
    @c = @c.rotateAround center, rotation
    this

  scale: (scale) ->
    center = @center()
    @a = center.add @a.subtract(center).scale(scale)
    @b = center.add @b.subtract(center).scale(scale)
    @c = center.add @c.subtract(center).scale(scale)
    this

  rotateAroundCenter: Triangle::rotate

  scaleAroundCenter: Triangle::scale

  closedGeometry: -> true

  points: -> [@a.clone(), @b.clone(), @c.clone(), @a.clone()]

  pointAtAngle: (angle) ->
    center = @center()
    vec = center.add Math.cos(angle)*10000,
                     Math.sin(angle)*10000
    @intersections(points: -> [center, vec])?[0]

  acreage: ->
    return @memoFor 'acreage' if @memoized 'acreage'
    @memoize 'acreage', @ab().length() *
                        @bc().length() *
                        Math.abs(Math.sin(@abc())) / 2

  contains: (x, y) ->
    p = new Point x, y

    v0 = @ac()
    v1 = @ab()
    v2 = p.subtract(@a)

    dot00 = v0.dot v0
    dot01 = v0.dot v1
    dot02 = v0.dot v2
    dot11 = v1.dot v1
    dot12 = v1.dot v2

    invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
    u = (dot11 * dot02 - dot01 * dot12) * invDenom
    v = (dot00 * dot12 - dot01 * dot02) * invDenom

    u > 0 and v > 0 and u + v < 1

  randomPointInSurface: (random) ->
    unless random?
      random = new chancejs.Random new chancejs.MathRandom

    a1 = random.get()
    a2 = random.get()
    p = @a.add(@ab().scale(a1))
          .add(@ca().scale(a2 * -1))

    if @contains p
      p
    else
      p.add @bcCenter().subtract(p).scale(2)

  length: -> @ab().length() + @bc().length() + @ca().length()

  pathPointAt: (n, pathBasedOnLength=true) ->
    [l1, l2] = @pathSteps pathBasedOnLength

    if n < l1
      @a.add @ab().scale Math.map n, 0, l1, 0, 1
    else if n < l2
      @b.add @bc().scale Math.map n, l1, l2, 0, 1
    else
      @c.add @ca().scale Math.map n, l2, 1, 0, 1

  pathOrientationAt: (n, pathBasedOnLength=true) ->
    [l1, l2] = @pathSteps pathBasedOnLength

    if n < l1
      @ab().angle()
    else if n < l2
      @bc().angle()
    else
      @ca().angle()

  pathSteps: (pathBasedOnLength) ->
    if pathBasedOnLength
      l = @length()
      l1 = @ab().length() / l
      l2 = l1 + @bc().length() / l
    else
      l1 = 1 / 3
      l2 = 2 / 3

    [l1,l2]

  drawPath: (context) ->
    context.beginPath()
    context.moveTo @a.x, @a.y
    context.lineTo @b.x, @b.y
    context.lineTo @c.x, @c.y
    context.lineTo @a.x, @a.y
    context.closePath()

  memoizationKey: -> "#{@a.x};#{@a.y};#{@b.x};#{@b.y};#{@c.x};#{@c.y}"

  triangleFrom: Triangle.triangleFrom

  ### Internal ###

  invalidPoint: (k,v) -> throw new Error "Invalid point #{v} for vertex #{k}"
