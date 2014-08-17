namespace('agt.mixins')
class agt.mixins.StateMachine
  @initial: (state) -> @initialState = state

  @event: (name, block) ->
    @::[name] = block

  @state: (name, defines) ->
    @states ?= {}
    @stateProperties ?= []

    @states[name] = defines
    @::[name] = -> @state is name
    @stateProperties.push(k) for k,v of defines when k not in @stateProperties

    this

  initializeStateMachine: -> @setState(@constructor.initialState)

  transition: (options) ->
    throw new Error("From option is mandatory") unless options.from?
    throw new Error("To option is mandatory") unless options.to?

    {from, to} = options
    if from is 'all'
      from = Object.keys(@constructor.states)
    else
      from = from.split(' ')

    to = options.to

    for f in from
      unless @constructor.states[f]
        throw new Error("From state '#{f}' does not match any defined state")

    unless @constructor.states[to]
      throw new Error("To state '#{to}' does not match any defined state")

    if @state in from
      @setState(to)
    else
      throw new Error "Can't transition from #{@state} to #{to}"

  setState: (state) ->
    @state = state
    state = @constructor.states[@state]
    @[key] = state[key] for key in @constructor.stateProperties
