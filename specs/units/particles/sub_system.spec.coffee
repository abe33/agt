
Point = agt.geom.Point
Particle = agt.particles.Particle
Limited = agt.particles.timers.Limited
ByRate = agt.particles.counters.ByRate
Ponctual = agt.particles.emitters.Ponctual
Life = agt.particles.initializers.Life
Live = agt.particles.actions.Live
Emission = agt.particles.Emission

SubSystem = agt.particles.SubSystem

describe 'SubSystem,', ->
  source = 'system'
  describe 'when instanciated with all its components,', ->

    beforeEach ->
      @initializer = initializer = new Life 1000
      @action = action = new Live
      @system = new SubSystem({
        initializer
        action
        emissionFactory: (particle) ->
          new Emission({
            class: Particle
            emitter: new Ponctual(particle.position.clone())
            timer: new Limited(1000,100)
            counter: new ByRate(10)
          })
      })

    createListener()

    it 'should exist', ->
      expect(@system).toBeDefined()
      expect(@system.initializer).toBe(@initializer)
      expect(@system.action).toBe(@action)

    system(source).shouldHave().signal('particlesCreated')
    system(source).shouldHave().signal('particlesDied')
    system(source).shouldHave().signal('emissionStarted')
    system(source).shouldHave().signal('emissionFinished')

    system(source).shouldHave(0).particles()
    system(source).shouldHave(0).emissions()

    describe 'when its emitFor method is called', ->
      describe 'with a particle', ->
        beforeEach ->
          @source = new Particle
          @source.init()
          @source.position.x = 10
          @source.position.y = 10
          @system.emitFor @source
          @particle = @system.particles[0]

        afterEach -> @system.stop()

        system(source).shouldHave(2).particles()
        system(source).shouldHave(1).emissions()
        system(source).shouldHave().dispatched('emissionStarted')
        system(source).shouldHave().dispatched('particlesCreated')
        system(source).shouldHave().started()
        system(source).should.emitting()

        particle('particle').maxLife.shouldBe(1000)
        particle('particle').life.shouldBe(100)

        describe 'when animating the system until the emission end,', ->
          beforeEach -> animate 1000

          system(source).should.not.emitting()
          system(source).shouldHave(9).particles()
          system(source).shouldHave(0).emissions()
          system(source).shouldHave().dispatched('emissionFinished')
          system(source).shouldHave().dispatched('particlesDied')

        describe 'when adding a second emission after some time,', ->
          beforeEach ->
            animate 500
            @system.emit new Emission(Particle)

            system(source).shouldHave(2).emissions()

            describe 'when animating past the life of the first emission,', ->
              beforeEach -> animate 600

              system(source).shouldHave(1).emissions()
