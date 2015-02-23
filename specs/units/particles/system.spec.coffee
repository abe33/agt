
Point = agt.geom.Point
Particle = agt.particles.Particle
Limited = agt.particles.timers.Limited
ByRate = agt.particles.counters.ByRate
Ponctual = agt.particles.emitters.Ponctual
Life = agt.particles.initializers.Life
Live = agt.particles.actions.Live
Emission = agt.particles.Emission

System = agt.particles.System
SubSystem = agt.particles.SubSystem

withMockRequestAnimationFrame ->
  describe 'System,', ->
    source = 'system'
    subSource = 'subSystem'
    describe 'when instanciated with all its components,', ->

      beforeEach ->
        @initializer = initializer = new Life 1000
        @action = action = new Live
        @subSystem = subSystem = new SubSystem({
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
        @system = new System({initializer, action, subSystem})

      createListener()

      it 'exists', ->
        expect(@system).toBeDefined()
        expect(@system.initializer).toBe(@initializer)
        expect(@system.action).toBe(@action)

      system(source).shouldHave().signal('particlesCreated')
      system(source).shouldHave().signal('particlesDied')
      system(source).shouldHave().signal('emissionStarted')
      system(source).shouldHave().signal('emissionFinished')

      system(source).shouldHave(0).particles()
      system(source).shouldHave(0).emissions()

      describe 'when its emit method is called', ->
        describe 'with an emission whose timer have since defined,', ->
          beforeEach ->
            @emission = new Emission({
              class: Particle
              emitter: new Ponctual(new Point)
              timer: new Limited(1000,100)
              counter: new ByRate(10)
              initializer:
                initialize: ->
              action:
                prepare: ->
                process: ->
            })
            @system.emit @emission
            @particle = @system.particles[0]

            spyOn(@emission.action, 'prepare')
            spyOn(@emission.action, 'process')
            spyOn(@emission.initializer, 'initialize')

          afterEach -> @system.stop()

          system(source).shouldHave(2).particles()
          system(source).shouldHave(1).emissions()
          system(source).shouldHave().dispatched('emissionStarted')
          system(source).shouldHave().dispatched('particlesCreated')
          system(source).shouldHave().started()
          system(source).should.emitting()


          emission('emission').system.shouldBe(source)
          particle('particle').maxLife.shouldBe(1000)
          particle('particle').life.shouldBe(100)

          describe 'when animating the system until the emission end,', ->
            beforeEach -> animate 1000

            system(source).should.not.emitting()
            system(source).shouldHave(10).particles()
            system(source).shouldHave(0).emissions()
            system(source).shouldHave().dispatched('emissionFinished')
            system(source).shouldHave().dispatched('particlesDied')

            system(subSource).shouldHave(4).particles()
            system(subSource).shouldHave(2).emissions()

            it 'calls the emission initializer', ->
              expect(@emission.initializer.initialize.calls.count()).toEqual(10)

            it 'calls the action prepare method', ->
              expect(@emission.action.prepare).toHaveBeenCalled()

            it 'calls the action process method', ->
              expect(@emission.action.process).toHaveBeenCalled()

          describe 'when adding a second emission after some time,', ->
            beforeEach ->
              animate 500
              @system.emit new Emission({class: Particle})

              system(source).shouldHave(2).emissions()

              describe 'when animating past the life of the first emission,', ->
                beforeEach -> animate 600

                system(source).shouldHave(1).emissions()

          describe '::removeEmission', ->
            beforeEach ->
              @system.removeEmission(@emission)

            system(source).shouldHave(0).emissions()

          describe '::removeAllEmissions', ->
            beforeEach ->
              @system.emit new Emission({class: Particle})
              @system.removeAllEmissions()

            system(source).shouldHave(0).emissions()
