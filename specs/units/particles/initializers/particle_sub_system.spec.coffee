Point = agt.geom.Point
Particle = agt.particles.Particle
Limited = agt.particles.timers.Limited
ByRate = agt.particles.counters.ByRate
Ponctual = agt.particles.emitters.Ponctual
Life = agt.particles.initializers.Life
Live = agt.particles.actions.Live
Emission = agt.particles.Emission
SubSystem = agt.particles.SubSystem
ParticleSubSystem = agt.particles.initializers.ParticleSubSystem

withMockRequestAnimationFrame ->
  describe 'ParticleSubSystem', ->
    describe 'when instanciated with system components', ->
      beforeEach ->
        @initializer = initializer = new Life 1000
        @action = action = new Live
        @initializer = new ParticleSubSystem({
          initializer
          action
          emissionFactory: (p) ->
            new Emission({
              class: Particle
              emitter: new Ponctual(p.position)
              timer: new Limited(1000,100)
              counter: new ByRate(10)
            })
        })

      it 'should have created a new sub system', ->
        expect(@initializer.subSystem).toBeDefined()

      describe 'when its initialize method is called', ->
        beforeEach ->
          @particle = new Particle
          @particle.init()
          @particle.position.x = 10
          @particle.position.y = 10
          @initializer.initialize @particle

        it 'should create a new emission for the given particle', ->
          expect(@initializer.subSystem.emissions.length).toBe(1)
