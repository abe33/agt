
canvasId = 1

defaults =
  width: 100
  height: 100

  circle:
    class: agt.geom.Circle
    defaults:
      radius: 40
      x: 50
      y: 50

    instance: (circle={}) ->
      circle[k] = v for k,v of @defaults when not circle[k]?

      new @class circle

    intersectionInstance: -> new @class 40, 100, 50

  rectangle:
    class: agt.geom.Rectangle
    defaults:
      x: 20
      y: 20
      width: 75
      height: 40
      rotation: Math.PI * 0.1

    instance: (rect={}) ->
      rect[k] = v for k,v of @defaults when not rect[k]?

      new @class rect

    intersectionInstance: ->
      new @class 60, 35, 80, 30

  render:
    angle: false
    paths: false
    contains: false
    center: false
    bounds: false
    center: false
    surface: false
    triangles: false
    vertices: false
    highlight: false

merge = (a,b) ->
  o = {}
  o[k] = v for k,v of a
  o[k] = v for k,v of b
  o

getCurrentScriptNode = -> $('script').last()

createCanvas = (width=defaults.width, height=defaults.height)->
  $("<canvas id='example-canvas-#{canvasId++}' width='#{width}' height='#{height}'></canvas>")[0]

window.drawGeometry = (key, options={}) ->
  lastScript = getCurrentScriptNode()
  geometry = defaults[key].instance(options.params)

  canvas = createCanvas(options.width, options.height)
  context = canvas.getContext('2d')

  renderer = new GeometryRenderer geometry, merge(defaults.render, options)

  renderer.render(context)

  lastScript.after(canvas)

  {geometry, canvas, context, renderer}

window.drawIntersectionsGeometries = (keyA, keyB, options={}) ->
  options.width ||= 150

  lastScript = getCurrentScriptNode()
  geometryA = defaults[keyA].instance(options.paramsA)
  geometryB = defaults[keyB].intersectionInstance()

  canvas = createCanvas(options.width, options.height)
  context = canvas.getContext('2d')

  rendererA = new GeometryRenderer geometryA, merge(defaults.render, options)
  rendererB = new GeometryRenderer geometryB, merge(defaults.render, options)

  rendererA.render(context)
  rendererB.render(context)

  lastScript.after(canvas)

  {geometryA, geometryB, canvas, context, rendererA, rendererB}

window.drawGeometryPoints = (key, methods..., options={}) ->
  [methods, options] = [methods.concat([options]), {}] if typeof options is 'string'
  {renderer, geometry, context} = drawGeometry(key, options)

  for method in methods
    pts = geometry[method]()
    pts = [pts] unless pts.push?

    for pt in pts
      renderer.renderSquarePoint(context, pt, 4, renderer.colorPalette.fill.highlight, renderer.colorPalette.stroke.highlight)

window.drawGeometryBound = (key, bound, options={}) ->
  {renderer, geometry, context, canvas} = drawGeometry(key, options)

  context.strokeStyle = renderer.colorPalette.bounds
  context.beginPath()
  if bound is 'top' or bound is 'bottom'
    y = geometry[bound]()
    context.moveTo(0, y)
    context.lineTo(canvas.width, y)
  else
    x = geometry[bound]()
    context.moveTo(x, 0)
    context.lineTo(x, canvas.height)

  context.stroke()

window.drawLineIntersections = (key, options={}) ->
  {renderer, geometry, context, canvas} = drawGeometry(key, options)

  a = new agt.geom.Point
  b = new agt.geom.Point canvas.width, canvas.height

  renderer.renderLine(context, a, b, renderer.colorPalette.intersections)
  geometry.eachLineIntersections a, b, (pt) ->
    renderer.renderSquarePoint(context, pt, 4, renderer.colorPalette.fill.highlight, renderer.colorPalette.stroke.highlight)

window.drawShapeIntersections = (keyA, keyB, options={}) ->
  {geometryA, geometryB, canvas, context, rendererA, rendererB} = drawIntersectionsGeometries(keyA, keyB, options)

  intersections = geometryA.intersections(geometryB)

  for pt in intersections
    rendererA.renderSquarePoint(context, pt, 4, rendererA.colorPalette.fill.highlight, rendererA.colorPalette.stroke.highlight)

window.drawGeometryEdge = (key, start, edge, options={}) ->
  {renderer, geometry, context, canvas} = drawGeometry(key, options)

  s = geometry[start]()
  v = geometry[edge]()

  context.strokeStyle = renderer.colorPalette.stroke.highlight
  context.beginPath()
  context.moveTo(s.x, s.y)
  context.lineTo(s.x + v.x, s.y + v.y)
  context.stroke()

window.drawTransform = (key, options={}) ->
  {renderer, geometry, context, canvas} = drawGeometry(key, options)

  geometry[options.type](options.args...)
  geometry.fill(context, renderer.colorPalette.fill.highlight)
  geometry.stroke(context, renderer.colorPalette.stroke.highlight)
