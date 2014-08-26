describe 'agt.mixins.Emitter', ->
  [emitter, subscription, spy] = []

  beforeEach ->
    class Dummy
      @include agt.mixins.Emitter

    emitter = new Dummy

  afterEach ->
    emitter.off()

  it 'have no listeners', ->
    expect(emitter.hasListeners('event')).toBeFalsy()

  describe 'when adding a listener', ->
    beforeEach ->
      spy = jasmine.createSpy('spy')
      subscription = emitter.on 'event', spy

    it 'adds the listener to the emitter', ->
      expect(emitter.hasListeners('event')).toBeTruthy()

      emitter.dispatch('event')

      expect(spy).toHaveBeenCalled()

    it 'removes it when calling the subscription off method', ->
      subscription.off()

      expect(emitter.hasListeners('event')).toBeFalsy()

      emitter.dispatch('event')

      expect(spy).not.toHaveBeenCalled()

    it 'removes it when calling the off method with the listener', ->
      emitter.off('event', spy)

      expect(emitter.hasListeners('event')).toBeFalsy()

    it 'removes it when calling the off method with only the event', ->
      emitter.off('event')

      expect(emitter.hasListeners('event')).toBeFalsy()

  describe 'when adding a listener once', ->
    beforeEach ->
      spy = jasmine.createSpy('spy')
      subscription = emitter.once 'event', spy

    it 'adds the listener to the emitter and removes it on dispatch', ->
      expect(emitter.hasListeners('event')).toBeTruthy()

      emitter.dispatch('event')

      expect(spy).toHaveBeenCalled()
      expect(emitter.hasListeners('event')).toBeFalsy()

      emitter.dispatch('event')
      expect(spy.calls.count()).toEqual(1)
