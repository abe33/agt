window.onload = ->
  [width, height] = []
  {Random, PaulHoule} = agt.random

  # GRADIENT = new agt.colors.Gradient([
  #   new agt.colors.Color('#3f7cac')
  #   new agt.colors.Color('#95afba')
  #   new agt.colors.Color('#bdc4a7')
  #   new agt.colors.Color('#d5e1a3')
  #   new agt.colors.Color('#e2f89c')
  # ], [0, 0.25, 0.5, 0.75, 1])

  GRADIENT = new agt.colors.Gradient([
    new agt.colors.Color('#A7FFF6')
    new agt.colors.Color('#95D9C3')
    new agt.colors.Color('#A4F9C8')
  ], [0, 0.5, 1])

  BASE_COLOR = new agt.colors.Color('#c1fff8')
  # BASE_COLOR = new agt.colors.Color('#8ED6F2')
  SHADOW_COLOR = new agt.colors.Color('#ccbbbb')
  LIGHT_COLOR = new agt.colors.Color('#bbe4F2')
  LIGHT_COLOR_2 = new agt.colors.Color('#88aabb')
  ACCENT_COLOR = new agt.colors.Color('#aaaa99')

  clearPositions = []
  colorsByPosition = {}

  measureWidthAndHeight = ->
    width = canvas.width = document.documentElement.clientWidth
    height = canvas.height = document.documentElement.clientHeight

  getKey = (position) -> "#{position.x};#{position.y}"

  getColor = (position) ->
    colorsByPosition[getKey(position)] ? BASE_COLOR

  drawTriangle = (context, color, a, b, c, r=1) ->
    context.fillStyle = color.transparentize(r).toCSS()
    context.beginPath()
    context.moveTo a.x, a.y
    context.lineTo b.x, b.y
    context.lineTo c.x, c.y
    context.lineTo a.x, a.y
    context.closePath()
    context.fill()

  clearTriangles = (context, grid) ->
    for [pos, color] in clearPositions
      colorsByPosition[getKey(pos)] = color
      {a,b,c} = grid.triangleAtPosition(pos)
      drawTriangle context, color, a, b, c

      key = getKey(pos)
      delete TriEmitter.consumedCoordinates[key]

    clearPositions = []

  fillTrianglesPositions = (context, grid) ->
    for pos,color of colorsByPosition
      [x,y] = pos.split(';').map(Number)
      {a,b,c} = grid.triangleAtPosition({x,y})
      drawTriangle(context, color, a, b, c)

  renderParticle = (context, grid, particle) ->
    return unless particle.position

    tri = grid.triangleAtPosition(particle.position)
    {a,b,c} = tri
    direction = particle.position.y % 2 is 0
    d = tri.center()

    lifeRatio = particle.life / particle.maxLife
    baseColor = getColor(particle.position)
    shadowColor = baseColor.blend(SHADOW_COLOR, agt.colors.BLEND_MODES.MULTIPLY)
    lightColor = baseColor.blend(LIGHT_COLOR, agt.colors.BLEND_MODES.SCREEN)
    lightColor2 = baseColor.blend(LIGHT_COLOR_2, agt.colors.BLEND_MODES.SOFT_LIGHT)
    accentColor = baseColor.blend(ACCENT_COLOR, agt.colors.BLEND_MODES.SOFT_LIGHT)

    if lifeRatio <= 0.5
      r = lifeRatio * 2

      drawTriangle context, baseColor, a, b, c

      if direction
        drawTriangle context, shadowColor, a, b, d, r
        drawTriangle context, lightColor, c, b, d, r
        drawTriangle context, accentColor, c, a, d, r
      else
        drawTriangle context, lightColor, a, c, d, r
        drawTriangle context, lightColor2, a, b, d, r
        drawTriangle context, shadowColor, b, c, d, r
    else
      r = lifeRatio - 0.5
      da = d.subtract(a).scale(r)
      db = d.subtract(b).scale(r)
      dc = d.subtract(c).scale(r)

      drawTriangle context, particle.parasite.color, a, b, c

      if direction
        drawTriangle context, lightColor, c, b, d.add(da)
        drawTriangle context, accentColor, c, a, d.add(db)
        drawTriangle context, shadowColor, a, b, d.add(dc)
      else
        drawTriangle context, lightColor, a, c, d.add(db)
        drawTriangle context, lightColor2, a, b, d.add(dc)
        drawTriangle context, shadowColor, b, c, d.add(da)

  stats = new Stats
  stats.setMode 0
  # 0: fps, 1: ms
  # align top-left
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.right = '0px'
  stats.domElement.style.top = '0px'

  document.body.appendChild stats.domElement

  agt.Impulse.instance().stats = stats

  seed = 1234 + Math.floor(Math.random() * 100000)
  random = new Random(new PaulHoule(seed))
  canvas = document.querySelector('canvas')
  context = canvas.getContext('2d')
  offCanvas = document.createElement('canvas')
  offContext = offCanvas.getContext('2d')
  counter = document.querySelector('#counter')
  grid = new agt.geom.HorizontalTriangleGrid(80)

  measureWidthAndHeight()

  class TriEmitter
    @consumedCoordinates: {}

    nextTime: 0
    count: 0
    lastTime: 0

    constructor: (@grid, @maxCells=100, @pointers=3, @radiusRange=new agt.geom.Range(20,100)) ->
      @circle = new agt.geom.Circle(@radiusRange.min, random.random(width), random.random(height))
      @consumedCells = 0

      angle = random.random(Math.PI * 2)
      length = random.inRange(1500, 2500)

      @velocity = agt.geom.Point.polar(angle, length)
      @angularVelocity = Math.PI

    prepare: (bias, biasInSeconds, time) ->
      return if time is @lastTime
      @lastTime = time
      @nextTime = bias

      step = (1 + Math.sin(Math.PI * 1.5 + (@consumedCells / @maxCells) * Math.PI * 2)) / 2

      @circle.x += @velocity.x * biasInSeconds
      @circle.y += @velocity.y * biasInSeconds
      @circle.radius = @radiusRange.interpolate(step)
      @circle.angle += @angularVelocity * biasInSeconds

      @velocity = @velocity.rotate((0.5 - random.random()) / 4)

      repulsion = new agt.geom.Point()
      repulsionAmount = 10

      halfWidth = width / 2
      halfHeight = height / 2

      if @circle.x < halfWidth
        t = 1 / (@circle.x / halfWidth)
        repulsion.x = (t*t) * repulsionAmount
      else
        t = 1 / ((width - @circle.x) / halfWidth)
        repulsion.x = (t*t) * -repulsionAmount

      if @circle.y < halfHeight
        t = 1 / (@circle.y / halfHeight)
        repulsion.y = (t*t) * repulsionAmount
      else
        t = 1 / ((height - @circle.y) / halfHeight)
        repulsion.y = (t*t) * -repulsionAmount

      @velocity = @velocity.add(repulsion).normalize(@velocity.length())

      @pendingCoordinates = []

      @checkPointers()

      @count = @pendingCoordinates.length

    checkPointers: ->
      for n in [0...@pointers]
        r = n/@pointers * Math.PI * 2

        pt = @circle.pointAtAngle(r)
        coordinates = @grid.screenToGrid(pt)
        key = getKey(coordinates)

        unless @constructor.consumedCoordinates[key]
          @constructor.consumedCoordinates[key] = true
          @consumedCells++
          @pendingCoordinates.push(new agt.geom.Point coordinates.x, coordinates.y)

    finished: -> @consumedCells >= @maxCells

    get: -> pt = @pendingCoordinates.shift()

  p = agt.particles

  system = new p.System(
    new p.initializers.Life(200,400),
    new p.actions.Live,
  )

  system.particlesDied.add (system, particles) ->
    for particle in particles
      continue unless particle.position
      clearPositions.push [particle.position, particle.parasite.color]

  emit = ->
    emitter = new TriEmitter(grid, random.inRange(100, 150))
    system.emit new p.Emission(
      p.Particle,
      emitter, emitter, emitter,
      initialize: (particle) ->
        r = (new Date().getTime() % 3000) / 3000
        r = (1 + Math.sin(Math.PI * 1.5 + r * Math.PI * 2)) / 2
        particle.parasite.color = GRADIENT.getColor(r)
    )

  emit()

  window.addEventListener 'resize', ->
    offCanvas.width = width
    offCanvas.height = height

    offContext.drawImage(canvas, 0, 0, width, height, 0, 0, width, height)

    measureWidthAndHeight()

    context.drawImage(offCanvas, 0, 0, offCanvas.width, offCanvas.height, 0, 0, offCanvas.width, offCanvas.height)

    fillTrianglesPositions(context, grid)

  t = 0
  agt.Impulse.instance().add (bias) ->
    # t += bias
    # if t > 2000
    #   t = t % 2000
    #   emit()


    particles = system.particles
    counter.innerHTML = """
      #{particles.length}<br/>
      #{system.emissions.length}<br/>
      #{seed}
    """

    for particle in particles
      renderParticle(context, grid, particle)

    clearTriangles(context, grid)
