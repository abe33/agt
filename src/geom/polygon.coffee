{Point,Triangulable,Geometry,Surface,Path,Intersections} = agt.geom

# Public:
class agt.geom.Polygon
  @extend mixins.Aliasable
  
  @include mixins.Formattable('Polygon', 'vertices')
  @include mixins.Sourcable('agt.geom.Polygon', 'vertices')
  @include mixins.Cloneable()
  @include Geometry
  @include Intersections
  @include Triangulable
  @include Surface
  @include Path

  ### Public ###

  @polygonFrom: (vertices) ->
    if vertices? and typeof vertices is 'object'
      isArray = Object::toString.call(vertices).indexOf('Array') isnt -1
      return vertices unless isArray
      {vertices}
    else
      vertices: null

  constructor: (vertices) ->
    {vertices} = @polygonFrom vertices

    @noVertices() unless vertices?
    @notEnougthVertices vertices if vertices.length < 3
    @vertices = vertices

  center: ->
    x = y = 0

    for vertex in @vertices
      x += vertex.x
      y += vertex.y

    x = x / @vertices.length
    y = y / @vertices.length

    new Point x, y

  translate: (x,y) ->
    {x,y} = Point.pointFrom x,y
    for vertex in @vertices
      vertex.x += x
      vertex.y += y
    this

  rotate: (rotation) ->
    center = @center()
    for vertex,i in @vertices
      @vertices[i] = vertex.rotateAround center, rotation
    this

  @alias 'rotate', 'rotateAroundCenter'

  scale: (scale) ->
    center = @center()
    for vertex,i in @vertices
      @vertices[i] = center.add vertex.subtract(center).scale(scale)
    this


  @alias 'scale', 'scaleAroundCenter'

  points: ->
    (vertex.clone() for vertex in @vertices).concat(@vertices[0].clone())

  closedGeometry: -> true

  pointAtAngle: (angle) ->
    center = @center()
    distance = (a,b) -> a.distance(center) - b.distance(center)
    vec = center.add Math.cos(angle)*10000,
                     Math.sin(angle)*10000
    @intersections(points: -> [center, vec])?.sort(distance)[0]

  acreage: ->
    acreage = 0
    acreage += tri.acreage() for tri in @triangles()
    acreage

  contains: (x,y) ->
    return true for tri in @triangles() when tri.contains x,y
    false

  randomPointInSurface: (random) ->
    unless random?
      random = new chancejs.Random new chancejs.MathRandom

    acreage = @acreage()
    triangles = @triangles()
    ratios = triangles.map (t, i) -> t.acreage() / acreage
    ratios[i] += ratios[i-1] for n,i in ratios when i > 0

    random.inArray(triangles, ratios, true).randomPointInSurface random

  length: ->
    length = 0
    points = @points()
    for i in [1..points.length-1]
      length += points[i-1].distance(points[i])
    length

  memoizationKey: -> @vertices.map((pt) -> "#{pt.x},#{pt.y}").join ";"

  ### Internal ###

  polygonFrom: Polygon.polygonFrom

  noVertices: ->
    throw new Error 'No vertices provided to Polygon'

  notEnougthVertices: (vertices) ->
    length = vertices.length
    throw new Error "Polygon must have at least 3 vertices, was #{length}"
