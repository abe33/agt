
withMockRequestAnimationFrame ->
  describe 'agt.Impulse', ->
    beforeEach ->
      @impulse = new agt.Impulse
      @listener = jasmine.createSpy('listener')

    describe 'running', ->
      beforeEach ->
        calls = 0
        spyOn(@impulse, 'getTime').and.callFake ->
          calls++
          calls * 1000

        @impulse.add @listener

        @nextAnimationFrame()

      it 'dispatches an event with the time data', ->
        expect(@listener.calls.argsFor(0)).toEqual([1000, 1, 2000])

      it 'honors the maxBias property', ->
        @impulse.maxBias = 500
        @nextAnimationFrame()
        expect(@listener.calls.argsFor(1)).toEqual([500, 0.5, 4000])

    describe 'when adding a listener', ->
      beforeEach ->
        @impulse.add @listener

      it 'adds the listener in the listeners array', ->
        expect(@impulse.listeners.length).toEqual(1)

      it 'starts itself', ->
        expect(@impulse.running).toBeTruthy()

      it 'does not add twice the same listener', ->
        @impulse.add @listener

        expect(@impulse.listeners.length).toEqual(1)

      describe 'with a message passed in dispatch', ->
        beforeEach ->
          @impulse.dispatch 'foo'

        it 'sends the message to the listener', ->
          expect(@listener).toHaveBeenCalled()

      describe 'removing a listener', ->
        beforeEach ->
          @impulse.remove @listener

        it 'removes the listener from the listeners array', ->
          expect(@impulse.listeners.length).toEqual(0)

        it 'stop itself', ->
          expect(@impulse.running).toBeFalsy()

    describe 'when adding a listener with a context', ->
      beforeEach ->
        @scope = {}
        @listener = -> @foo = 'bar'

        @impulse.add @listener, @scope

      it 'calls the listener in the given context', ->
        @impulse.dispatch()

        expect(@scope.foo).toEqual('bar')

      it 'accepts twice the same listener with different scope', ->
        @impulse.add @listener, {}

        expect(@impulse.listeners.length).toEqual(2)

      it 'removes the listener only with its context', ->
        @impulse.remove @listener

        expect(@impulse.listeners.length).toEqual(1)

        @impulse.remove @listener, @scope

        expect(@impulse.listeners.length).toEqual(0)

    describe '::addOnce', ->
      describe 'called with a listener', ->
        beforeEach ->
          @impulse.addOnce @listener

        it 'adds the listener in the listeners array', ->
          expect(@impulse.listeners.length).toEqual(1)

        it 'removes the listener after the first dispatch', ->
          @impulse.dispatch()

          expect(@impulse.listeners.length).toEqual(0)

    describe 'adding listeners with priority', ->
      beforeEach ->
        @listenersCalls = []
        @listener1 = => @listenersCalls.push 'listener1'
        @listener2 = => @listenersCalls.push 'listener2'

        @impulse.add @listener1
        @impulse.add @listener2, null, 1

      it 'calls the listeners in order', ->
        @impulse.dispatch()

        expect(@listenersCalls).toEqual([
          'listener2'
          'listener1'
        ])

    describe 'adding listeners with priority once', ->
      beforeEach ->
        @listenersCalls = []
        @listener1 = => @listenersCalls.push 'listener1'
        @listener2 = => @listenersCalls.push 'listener2'

        @impulse.addOnce @listener1
        @impulse.addOnce @listener2, null, 1

      it 'calls the listeners in order', ->
        @impulse.dispatch()

        expect(@listenersCalls).toEqual([
          'listener2'
          'listener1'
        ])

        expect(@impulse.listeners.length).toEqual(0)

    it 'removes all listeners at once', ->
      signal = new agt.Signal

      listener1 = ->
      listener2 = ->

      signal.add listener1
      signal.add listener2

      signal.removeAll()
      expect(signal.listeners.length).toBe(0)
