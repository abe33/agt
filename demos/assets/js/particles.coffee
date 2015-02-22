window.onload = ->
  stats = new Stats
  stats.setMode 0
  # 0: fps, 1: ms
  # align top-left
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.right = '0px'
  stats.domElement.style.top = '0px'
  document.body.appendChild stats.domElement

  canvas = document.querySelector('canvas')
  context = canvas.getContext('2d')
  p = require('agt/particles')
  Point = require('agt/geom/point')
  Impulse = require('agt/impulse')

  particleSubSystem = new p.initializers.ParticleSubSystem({
    initializer: new p.initializers.Life(800,1200)
    action: new p.actions.MacroAction([
      new p.actions.Live,
      new p.actions.Move,
      new p.actions.Force(new Point(5, 20))
      new p.actions.Friction(0.2)
    ])
    emissionFactory: (particle) ->
      new p.Emission({
        class: p.Particle
        emitter: new p.emitters.Ponctual(particle.position)
        timer: new p.timers.UntilDeath(particle)
        counter: new p.counters.ByRate(10)
        initializer:
          initialize: (particle) -> particle.parasite.color = '#00ff00'
      })
  })

  system = new p.System({
    initializer: new p.initializers.MacroInitializer([
      new p.initializers.Life(3000,4000),
      particleSubSystem
    ])
    action: new p.actions.MacroAction([
      new p.actions.Live,
      new p.actions.Move,
      new p.actions.Force(new Point(5, 20))
      new p.actions.Friction(0.2)
    ])
    subSystem: new p.SubSystem({
      initializer: new p.initializers.Life(800,1200)
      action: new p.actions.MacroAction([
        new p.actions.Live,
        new p.actions.Move,
        new p.actions.Force(new Point(5, 20))
        new p.actions.Friction(0.2)
      ])
      emissionFactory: (particle) ->
        new p.Emission({
          class: p.Particle
          emitter: new p.emitters.Ponctual(particle.position.clone())
          timer: new p.timers.Limited(10)
          counter: new p.counters.Fixed(20)
          initializer: new p.initializers.MacroInitializer([
            new p.initializers.Explosion(10,20),
            initialize: (particle) -> particle.parasite.color = '#ff0000'
          ])
        })
    })
  })

  # system.particlesCreated.add (o,p) -> console.log 'particlesCreated'
  # system.particlesDied.add (o,p) -> console.log 'particlesDied'
  # system.emissionStarted.add (o,p) -> console.log 'emissionStarted'
  # system.emissionFinished.add (o,p) -> console.log 'emissionFinished'

  Impulse.instance().stats = stats

  canvas.addEventListener 'click', ({clientX, clientY}) ->
    unless Impulse.instance().running
      Impulse.instance().add ->
        context.fillStyle = '#ffffff'
        context.fillRect(0,0,canvas.width,canvas.height)

        particles = system.particles
        particles = particles.concat(system.subSystem.particles)
        particles = particles.concat(particleSubSystem.subSystem.particles)
        for particle in particles
          context.fillStyle = particle.parasite.color
          context.fillRect(particle.position.x, particle.position.y, 1, 1)

    x = clientX
    y = clientY
    system.emit new p.Emission({
      class: p.Particle,
      emitter: new p.emitters.Ponctual(new Point(x, y)),
      timer: new p.timers.Unlimited,
      counter: new p.counters.ByRate(1),
      initializer: new p.initializers.MacroInitializer([
        new p.initializers.Stream(new Point(1,-3),40,50,0.2),
        initialize: (particle) -> particle.parasite.color = '#000000'
      ])
    })
