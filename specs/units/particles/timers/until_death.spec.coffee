UntilDeath = agt.particles.timers.UntilDeath
Particle = agt.particles.Particle

describe 'UntilDeath', ->
  describe 'when instanciated with a particle', ->
    source = 'timer'
    beforeEach ->
      @particle = new Particle
      @particle.init()
      @timer = new UntilDeath @particle

    timer(source).should.not.beFinished()

    describe 'when animated until the particle died', ->
      beforeEach ->
        @timer.prepare 500, 0.5, 500
        @particle.die()

      timer(source).should.beFinished()
