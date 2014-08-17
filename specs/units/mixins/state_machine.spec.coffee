describe 'StateMachine', ->
  [dummy] = []

  beforeEach ->
    class Dummy
      @concern agt.mixins.StateMachine

      @initial 'birth'

      @event 'live', ->
        @transition from: 'birth', to: 'life'

      @event 'die', ->
        @transition from: 'life', to: 'death'

      @event 'reincarnate', ->
        @transition from: 'death', to: 'birth'

      @event 'disappear', ->
        @transition from: 'all', to: 'void'

      @event 'noTo', ->
        @transition from: 'birth'

      @event 'noFrom', ->
        @transition to: 'birth'

      @event 'undefinedToState', ->
        @transition from: 'birth', to: 'foo'

      @event 'undefinedFromState', ->
        @transition from: 'foo', to: 'death'

      @state 'birth', {
        talk: -> '...waaahahaahaAAHAAAHAAA'
        age: 0
      }

      @state 'life', {
        talk: -> 'I am alive'
        age: 20
      }

      @state 'death', {
        talk: -> '...'
        age: 80
      }

      @state 'void', {}

      constructor: ->
        @initializeStateMachine()

    dummy = new Dummy

  it 'initialize the instance in the initial state', ->
    expect(dummy.state).toEqual('birth')
    expect(dummy.birth()).toBeTruthy()
    expect(dummy.talk()).toEqual('...waaahahaahaAAHAAAHAAA')
    expect(dummy.age).toEqual(0)

  describe 'calling an event', ->
    it 'changes the machine to the end state', ->
      dummy.live()

      expect(dummy.state).toEqual('life')
      expect(dummy.live()).toBeTruthy()
      expect(dummy.talk()).toEqual('I am alive')
      expect(dummy.age).toEqual(20)

    describe 'that defines no properties', ->
      it 'removes the properties from the machine', ->
        dummy.disappear()

        expect(dummy.state).toEqual('void')
        expect(dummy.void()).toBeTruthy()
        expect(dummy.talk).toBeUndefined()
        expect(dummy.age).toBeUndefined()

    describe 'that initiates an invalid transition', ->
      it 'throws an error when end state is not defined', ->
        expect(-> dummy.noTo()).toThrow()

      it 'throws an error when start state is not defined', ->
        expect(-> dummy.noFrom()).toThrow()

      it 'throws an error when end state was not defined', ->
        expect(-> dummy.undefinedToState()).toThrow()

      it 'throws an error when start state was not defined', ->
        expect(-> dummy.undefinedFromState()).toThrow()

      it 'throws an error when current state does not match the start state', ->
        expect(-> dummy.die()).toThrow()
