
global.rectangle = (x, y, width, height, rotation) ->
  new agt.geom.Rectangle x, y, width, height, rotation

global.addRectangleMatchers = (scope) ->
  jasmine.addMatchers
    toBeRectangle: ->
      compare: (actual,x=0, y=0, width=0, height=0, rotation=0) ->
        result = {}
        result.message = "Expect #{actual} to be a rectangle equals to (#{x},#{y},#{width},#{height},#{rotation})"

        result.pass = actual.x is x and
        actual.y is y and
        actual.width is width and
        actual.height is height and
        actual.rotation is rotation

        result

global.testRotatedRectangle = (source, x, y, width, height, rotation) ->
  data = rectangleData x, y, width, height, rotation

  methods = [
    'topLeft'
    'topRight'
    'bottomLeft'
    'bottomRight'
    'topEdge'
    'bottomEdge'
    'leftEdge'
    'rightEdge'
    'center'
    'topEdgeCenter'
    'bottomEdgeCenter'
    'leftEdgeCenter'
    'rightEdgeCenter'
    'diagonal'
  ]
  bounds = [
    'top'
    'bottom'
    'left'
    'right'
  ]

  methods.forEach (m) ->
    pointOf(source, m).shouldBe(data[m])

  bounds.forEach (k) ->
    describe "the #{source} #{k} method", ->
      it "returns #{data[k]}", ->
        expect(@[source][k]()).toBeClose(data[k])

global.rectangleData = (x=0, y=0, width=0, height=0, rotation=0) ->
  {x,y,width,height,rotation} = x if typeof x is 'object'

  xTopEdge = width * Math.cos rotation
  yTopEdge = width * Math.sin rotation

  xLeftEdge = height * Math.cos rotation + Math.PI / 2
  yLeftEdge = height * Math.sin rotation + Math.PI / 2

  source = "new agt.geom.Rectangle(#{x},#{y},#{width},#{height},#{rotation})"

  topEdge:
    x: xTopEdge
    y: yTopEdge
  leftEdge:
    x: xLeftEdge
    y: yLeftEdge
  bottomEdge:
    x: xTopEdge
    y: yTopEdge
  rightEdge:
    x: xLeftEdge
    y: yLeftEdge
  diagonal:
    x: xLeftEdge + xTopEdge
    y: yLeftEdge + yTopEdge
  topLeft:
    x: x
    y: y
  topRight:
    x: x + xTopEdge
    y: y + yTopEdge
  bottomRight:
    x: x + xTopEdge + xLeftEdge
    y: y + yTopEdge + yLeftEdge
  bottomLeft:
    x: x + xLeftEdge
    y: y + yLeftEdge
  topEdgeCenter:
    x: x + xTopEdge / 2
    y: y + yTopEdge / 2
  bottomEdgeCenter:
    x: x + xLeftEdge + xTopEdge / 2
    y: y + yLeftEdge + yTopEdge / 2
  leftEdgeCenter:
    x: x + xLeftEdge / 2
    y: y + yLeftEdge / 2
  rightEdgeCenter:
    x: x + xTopEdge + xLeftEdge / 2
    y: y + yTopEdge + yLeftEdge / 2
    # Centers
  center:
    x: x + xTopEdge / 2 + xLeftEdge / 2
    y: y + yTopEdge / 2 + yLeftEdge / 2
  topEdgeCenter:
    x: x + xTopEdge / 2
    y: y + yTopEdge / 2
  bottomEdgeCenter:
    x: x + xTopEdge / 2 + xLeftEdge
    y: y + yTopEdge / 2 + yLeftEdge
  leftEdgeCenter:
    x: x + xLeftEdge / 2
    y: y + yLeftEdge / 2
  rightEdgeCenter:
    x: x + xLeftEdge / 2 + xTopEdge
    y: y + yLeftEdge / 2 + yTopEdge
  top: Math.min y, y+yTopEdge, y+yLeftEdge, y+yTopEdge+yLeftEdge
  bottom: Math.max y, y+yTopEdge, y+yLeftEdge, y+yTopEdge+yLeftEdge
  left: Math.min x, x+xTopEdge, x+xLeftEdge, x+xTopEdge+xLeftEdge
  right: Math.max x, x+xTopEdge, x+xLeftEdge, x+xTopEdge+xLeftEdge
  source: source
