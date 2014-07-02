class agt.Promise
  @unit: (value=0) ->
    promise = new agt.Promise
    promise.resolve value
    promise

  @all: (promises) ->
    promise = new agt.Promise
    solved = 0
    results = []

    promises.forEach (p) ->
      p
      .then (value) ->
        solved++
        results[promises.indexOf p] = value
        promise.resolve results if solved is promises.length

      .fail (reason) ->
        promise.reject reason

    promise

  constructor: (@factory) ->
    @pending = true
    @started = false
    @fulfilled = null
    @value = undefined
    @timeout = 60000
    @message = 'Timed out'

    @fulfilledHandlers = []
    @errorHandlers = []
    @progressHandlers = []

  isPending: -> @pending
  isResolved: -> not @pending
  isFulfilled: -> not @pending and @fulfilled
  isRejected: -> not @pending and not @fulfilled

  then: (fulfilledHandler, errorHandler, progressHandler) ->
    @start() unless @started
    promise = new agt.Promise
    f = (value)->
      try
        res = fulfilledHandler? value
      catch err
        promise.reject err
        return

      if res?.then?
        res
        .then (value) ->
          promise.resolve value
        .fail (reason) ->
          promise.reject reason
      else
        promise.resolve res

    e = (reason) ->
      errorHandler? reason
      promise.reject reason

    if @pending
      @fulfilledHandlers.push f
      @errorHandlers.push e
      @progressHandlers.push progressHandler if progressHandler?
    else
      if @fulfilled
        f @value
      else
        e @reason

    promise

  fail: (errorHandler) -> @then (->), errorHandler

  bind: (promise) ->
    @then ((res) -> promise.resolve(res)), ((reason) -> promise.reject(reason))

  resolve: (@value) ->
    return unless @pending

    @fulfilled = true
    @notifyHandlers()
    @pending = false

  reject: (reason) ->
    return unless @pending

    @reason = reason
    @fulfilled = false
    @pending = false
    @notifyHandlers()

  start: ->
    return if @started

    if @factory?
      try
        if @signature(@factory).length is 0
          @resolve(@factory.call this)
        else
          lastTime = new Date()

          f = =>
            @reject new Error @message if new Date() - lastTime >= @timeout
            setTimeout f, 10 if @pending

          @factory.call(this, this)
          f()
      catch e
        @reject e

    @started = true

  rejectAfter: (@timeout, @message) ->

  notifyHandlers: ->
    if @fulfilled
      handler @value for handler in @fulfilledHandlers
    else
      handler @reason for handler in @errorHandlers

  signature: (func) ->
    re = ///
      ^function
      (\s+[a-zA-Z_][a-zA-Z0-9_]*)*
      \s*\(([^\)]+)\)
      ///
    re.exec(func.toString())?[2].split(/\s*,\s*/) or []
