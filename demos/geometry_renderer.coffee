class GeometryRenderer

  colorPalette =
    stroke:
      base: '#dedede'
      highlight: '#ff0000'
      over: '#859900'

    fill:
      base: 'rgba(245,245,245,0.3)'
      highlight: 'rgba(255,0,0,0.3)'
      over: 'rgba(133, 153, 0, 0.3)'

    bounds: 'rgba(133, 153, 0, 0.5)'
    intersections: '#268bd2'
    text: '#93a1a1'
    mobile: '#b58900'
    vertices: '#d33682'
    verticesConnections: 'rgba(211,54,130,0.5)'

  colorPalette: colorPalette

  constructor: (@geometry, @options={}) ->
    @baseState = @state = if @options.highlight then 'highlight' else 'base'
    @pathPosition = 0
    @random = new agt.random.Random new agt.random.MathRandom
    @name = @geometry.classname().toLowerCase()
    @angle = 0
    @angleSpeed = @random.in(1,3) * @random.sign()

  renderShape: (context) ->
    @geometry.fill(context, colorPalette.fill[@state])
    @geometry.stroke(context, colorPalette.stroke[@state])

  renderPaths: (context) ->
    for path in @options.paths
      pt = @geometry.pathPointAt(path, false)
      tan = @geometry.pathOrientationAt(path, false)

      if pt? and tan?
        tr = new agt.geom.Rectangle(pt.x,pt.y,6,6,tan)
        tr.stroke(context, colorPalette.mobile)

  renderSurface: (context) ->
    context.fillStyle = colorPalette.stroke.highlight
    for i in [0..200]
      pt = @geometry.randomPointInSurface @random
      context.beginPath()
      context.arc(pt.x, pt.y, 1, 0, Math.PI * 2) if pt?
      context.fill()

  renderContains: (context) ->
    for i in [0..200]
      pt = x: @random.random(100), y: @random.random(100)

      if @geometry.contains(pt)
        context.fillStyle = colorPalette.stroke.over
      else
        context.fillStyle = colorPalette.stroke.highlight

      context.beginPath()
      context.arc(pt.x, pt.y, 1, 0, Math.PI * 2)
      context.fill()

  renderTriangles: (context) ->
    triangles = @geometry.triangles()
    for tri in triangles
      tri.stroke context, colorPalette.stroke.highlight
      tri.fill context, colorPalette.fill.highlight

  renderBounds: (context) ->
    context.strokeStyle = colorPalette.bounds
    r = @geometry.boundingBox()
    context.strokeRect(r.x, r.y, r.width, r.height)  if r?

  renderCenter: (context) ->
    center = @geometry.center()

    context.fillStyle = colorPalette.stroke.highlight
    context.fillRect(center.x - 1, center.y - 8, 2, 16)
    context.fillRect(center.x - 8, center.y - 1, 16, 2)

  renderSquarePoint: (context, pt, size, fill, stroke) ->
    context.fillStyle = fill
    context.strokeStyle = stroke

    context.fillRect(pt.x-size/2, pt.y-size/2, size, size)
    context.strokeRect(pt.x-size/2, pt.y-size/2, size, size)

  renderCirclePoint: (context, pt, size, fill, stroke) ->
    context.fillStyle = fill
    context.strokeStyle = stroke

    context.arc pt.x, pt.y, size, 0, Math.PI * 2

  renderLine: (context, a, b, color) ->
    context.strokeStyle = color

    context.beginPath()
    context.moveTo(a.x,a.y)
    context.lineTo(b.x,b.y)
    context.stroke()

  renderAngle: (context) ->
    c = @geometry.center()
    pt1 = @geometry.pointAtAngle(@angle)
    pt2 = @geometry.pointAtAngle(@angle-Math.PI * 2 / 3)
    pt3 = @geometry.pointAtAngle(@angle+Math.PI * 2 / 3)

    if pt1? and pt2? and pt3?
      fillStyle = colorPalette.intersections
      strokeStyle = colorPalette.intersections

      @renderSquarePoint context, pt1, 4, fillStyle, strokeStyle
      @renderSquarePoint context, pt2, 4, fillStyle, strokeStyle
      @renderSquarePoint context, pt3, 4, fillStyle, strokeStyle

      context.beginPath()
      context.moveTo(pt1.x,pt1.y)
      context.lineTo(c.x,c.y)
      context.lineTo(pt2.x,pt2.y)
      context.moveTo(c.x,c.y)
      context.lineTo(pt3.x,pt3.y)
      context.stroke()

  renderVertices: (context) ->
    @geometry.drawVertices context, colorPalette.vertices
    @geometry.drawVerticesConnections context, colorPalette.verticesConnections

  render: (context) ->
    if @geometry.stroke? and @geometry.fill?
      @renderShape context

    if @options.bounds and @geometry.bounds?
      @renderBounds context

    if @options.paths and @geometry.pathPointAt? and @geometry.pathOrientationAt?
      @renderPaths context

    if @options.surface and @geometry.randomPointInSurface?
      @renderSurface context

    if @options.triangles and @geometry.triangles?
      @renderTriangles context

    if @options.angle and @geometry.center? and @geometry.pointAtAngle?
      @renderAngle context

    if @options.vertices and @geometry.drawVertices?
      @renderVertices context

    if @options.center and @geometry.center?
      @renderCenter context

    if @options.contains and @geometry.contains?
      @renderContains context
