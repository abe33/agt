
window.onload = ->
  canvas = document.body.querySelector('canvas')
  context = canvas.getContext('2d')
  {Point, Polygon, Triangle} = agt.geom
  {Random, PaulHoule} = agt.random

  stats = new Stats
  stats.setMode 0
  # 0: fps, 1: ms
  # align top-left
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.right = '0px'
  stats.domElement.style.top = '0px'

  scrollContainer = document.body.querySelector('.page-wrapper')

  document.body.appendChild stats.domElement

  time = new Date().getTime()
  width = canvas.width = document.documentElement.clientWidth
  height = canvas.height = document.documentElement.clientHeight
  # height = 800
  foldSize = 300
  seed = 123456 #new Date().getFullYear() + new Date().getMonth()
  random = new Random(new PaulHoule(seed))

  camera = new agt.scenes.Camera

  class RotatingPolygon
    constructor: (center, @random, @angularVelocity=0, @parallax=1, colors=[]) ->
      @rotation = 0
      @color = @getColor(colors)

      step = Math.PI * 2 / 6
      vertices = []
      for i in [0...6]
        angle = i * step
        length = random.inRange(100,800)
        vertices.push new Point(
          center.x + Math.cos(angle) * length,
          center.y + Math.sin(angle) * length
        )

      @polygon = new Polygon(vertices)

    animate: (delta) ->
      @polygon.rotate(@angularVelocity * delta)

    draw: (context) ->
      @polygon.fill(context, @color)

    boundsCollide: (geom) -> @polygon.boundsCollide(geom)

    setPosition: (newX,newY) ->
      {x,y} = @polygon.center()
      @polygon.translate(newX - x, newY - y)

    getColor: (colors) ->
      random.inArray(colors)

  class Screen
    constructor: (@position, @random, @color='#8ED6F2', colors=[]) ->
      @polygons = []

      for x in [0...12]
        center = new Point(
          @position.x + random.inRange(-100, width + 100),
          @position.y + random.inRange(foldSize, height)
        )
        @polygons.push(new RotatingPolygon(center, @random, @random.inRange(-0.05, 0.05), @random.random(), colors))

    animate: (delta) ->
      polygon.animate(delta) for polygon in @polygons

    draw: (context) ->
      for polygon in @polygons
        if polygon.boundsCollide(camera.screen)
          polygon.draw(context)

  screens = []

  width = canvas.width = document.documentElement.clientWidth
  height = canvas.height = document.documentElement.clientHeight

  screens.push new Screen(new Point, random, null, [
    'rgba(190, 230, 255, 0.9)'
    'rgba(190, 250, 245, 0.7)'
    'rgba(220, 250, 245, 0.8)'
    'rgba(200, 240, 245, 0.9)'
    'rgba(160, 230, 255, 0.7)'
    'rgba(230, 250, 220, 0.8)'
    'rgba(190, 250, 245, 0.9)'
    'rgba(230, 250, 220, 0.7)'
  ])
  screens.push new Screen(new Point(width, 0), random, '#ecdaee', [
    'rgba(240, 230, 200, 0.9)'
    'rgba(240, 200, 245, 0.7)'
    'rgba(220, 250, 245, 0.8)'
    'rgba(230, 200, 205, 0.9)'
    'rgba(230, 220, 255, 0.7)'
    'rgba(255, 210, 220, 0.8)'
    'rgba(190, 200, 245, 0.9)'
    'rgba(230, 240, 220, 0.7)'
  ])
  screens.push new Screen(new Point(width * 2, 0), random, '#ece3aa', [
    'rgba(230, 230, 200, 0.9)'
    'rgba(210, 210, 225, 0.7)'
    'rgba(240, 230, 205, 0.8)'
    'rgba(240, 240, 170, 0.9)'
    'rgba(230, 220, 215, 0.7)'
    'rgba(230, 250, 220, 0.8)'
    'rgba(230, 230, 200, 0.9)'
    'rgba(240, 230, 220, 0.7)'
  ])

  animate = ->
    t = new Date().getTime()
    delta = (t-time) / 1000
    time = t

    context.clearRect(0,0,canvas.width, canvas.height)
    context.translate(-camera.screen.x, -camera.screen.y)

    for screen in screens
      screen.animate(delta)
      screen.draw(context)

    context.setTransform(1, 0, 0, 1, 0, 0)

  targetX = screens[0].position.x

  moveToScreen = (screen) ->
    canvas.style.background = screen.color
    targetX = screen.position.x

  animateAndRequest = ->
    stats.begin()

    if Math.floor(camera.screen.x) isnt targetX
      camera.screen.x += (targetX - camera.screen.x) / 20

      animate()

    requestAnimationFrame(animateAndRequest)
    stats.end()

  requestAnimationFrame(animateAndRequest)
  animate()

  n = 0
  setInterval ->
    if n % 3 is 0
      moveToScreen(screens[2])
    else if n % 3 is 1
      moveToScreen(screens[1])
    else
      moveToScreen(screens[0])

    n++

  , 10000
