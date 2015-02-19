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
  p = agt.particles

  particleSubSystem = new p.initializers.ParticleSubSystem(
    new p.initializers.Life(800,1200),
    new p.actions.MacroAction([
      new p.actions.Live,
      new p.actions.Move,
      new p.actions.Force(new agt.geom.Point(5, 20))
      new p.actions.Friction(0.2)
    ]),
    (particle) ->
      new p.Emission(
        p.Particle,
        new p.emitters.Ponctual(particle.position),
        new p.timers.UntilDeath(particle),
        new p.counters.ByRate(10),
        initialize: (particle) -> particle.parasite.color = '#00ff00'
      )
  )

  system = new p.System(
    new p.initializers.MacroInitializer([
      new p.initializers.Life(3000,4000),
      particleSubSystem
    ]),
    new p.actions.MacroAction([
      new p.actions.Live,
      new p.actions.Move,
      new p.actions.Force(new agt.geom.Point(5, 20))
      new p.actions.Friction(0.2)
    ]),
    new p.SubSystem(
      new p.initializers.Life(800,1200),
      new p.actions.MacroAction([
        new p.actions.Live,
        new p.actions.Move,
        new p.actions.Force(new agt.geom.Point(5, 20))
        new p.actions.Friction(0.2)
      ]),
      (particle) ->
        new p.Emission(
          p.Particle,
          new p.emitters.Ponctual(particle.position.clone()),
          new p.timers.Limited(10),
          new p.counters.Fixed(20),
          new p.initializers.MacroInitializer([
            new p.initializers.Explosion(10,20),
            initialize: (particle) -> particle.parasite.color = '#ff0000'
          ])
        )
    )
  )

  # system.particlesCreated.add (o,p) -> console.log 'particlesCreated'
  # system.particlesDied.add (o,p) -> console.log 'particlesDied'
  # system.emissionStarted.add (o,p) -> console.log 'emissionStarted'
  # system.emissionFinished.add (o,p) -> console.log 'emissionFinished'

  agt.Impulse.instance().stats = stats

  canvas.addEventListener 'click', ({clientX, clientY}) ->
    unless agt.Impulse.instance().running
      agt.Impulse.instance().add ->

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
    system.emit new p.Emission(
      p.Particle,
      new p.emitters.Ponctual(new agt.geom.Point(x, y)),
      new p.timers.Unlimited,
      new p.counters.ByRate(1),
      new p.initializers.MacroInitializer([
        new p.initializers.Stream(new agt.geom.Point(1,-3),40,50,0.2),
        initialize: (particle) -> particle.parasite.color = '#000000'
      ])
    )
