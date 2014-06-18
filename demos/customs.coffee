
canvasId = 1

defaults =
  width: 100
  height: 100

  circle:
    klass: agt.geom.Circle
    instance: new agt.geom.Circle 40, 50, 50

  rectangle:
    klass: agt.geom.Rectangle
    instance: new agt.geom.Rectangle 10, 30, 80, 40

  render:
    angle: false
    path: false
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
  geometry = defaults[key].instance

  canvas = createCanvas()
  context = canvas.getContext('2d')

  renderer = new GeometryRenderer geometry, merge(defaults.render, options)

  renderer.render(context)

  lastScript.after(canvas)

  {geometry, canvas, context, renderer}

window.drawGeometryPoints = (key, methods..., options={}) ->
  [methods, options] = [methods.concat([options]), {}] if typeof options is 'string'
  {renderer, geometry, context} = drawGeometry(key, options)

  for method in methods
    pts = geometry[method]()

    pts = [pts] unless pts.push?

    console.log pts

    for pt in pts
      renderer.renderSquarePoint(context, pt, 4, renderer.colorPalette.fill.highlight, renderer.colorPalette.stroke.highlight)

window.drawGeometryBound = (key, bound, options={}) ->
  {renderer, geometry, context} = drawGeometry(key, options)

  if bound is 'top' or bound is 'bottom'
    pt = new agt.geom.Point geometry.center().x, geometry[bound]()
  else
    pt = new agt.geom.Point geometry[bound](), geometry.center().y

  renderer.renderSquarePoint(context, pt, 4, renderer.colorPalette.fill.highlight, renderer.colorPalette.stroke.highlight)

window.drawLineIntersections = (key, options={}) ->
  {renderer, geometry, context, canvas} = drawGeometry(key, options)

  a = new agt.geom.Point
  b = new agt.geom.Point canvas.width, canvas.height

  renderer.renderLine(context, a, b, renderer.colorPalette.intersections)
  geometry.eachLineIntersections a, b, (pt) ->
    renderer.renderSquarePoint(context, pt, 4, renderer.colorPalette.fill.highlight, renderer.colorPalette.stroke.highlight)
