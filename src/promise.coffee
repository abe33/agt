# Public: A lightweight implementation of promises.
module.exports =
class Promise

  ### Public ###

  # Returns an already fulfilled promise with the passed-in `value`.
  #
  # value - The promise's value.
  #
  # Returns a [Promise]{Promise}.
  @unit: (value=0) ->
    new Promise -> value

  # Returns a promise that is fulfilled when all the passed-in have been
  # fulfilled. The value of all the promised are provided in the returned
  # promise value.
  # If one of the promises fails, the returned promise is rejected.
  #
  # promises - An {Array} of promises
  #
  # Returns a [Promise]{Promise}.
  @all: (promises) ->
    promise = new Promise
    solved = 0
    results = []

    promises.forEach (p ,i) ->
      p
      .then (value) ->
        solved++
        results[i] = value
        promise.resolve results if solved is promises.length

      .fail (reason) ->
        promise.reject reason

    promise

  # Creates a new Promise.
  #
  # factory - The {Function} to call to resolve the created promise.
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

  # Returns `true` if the promise has not been resolved.
  #
  # Returns a {Boolean}.
  isPending: -> @pending

  # Returns `true` if the promise has been resolved.
  #
  # Returns a {Boolean}.
  isResolved: -> not @pending

  # Returns `true` if the promise has been resolved successfully.
  #
  # Returns a {Boolean}.
  isFulfilled: -> not @pending and @fulfilled

  # Returns `true` if the promise has been resolved by a rejection.
  #
  # Returns a {Boolean}.
  isRejected: -> not @pending and not @fulfilled

  # Registers callbacks to the promise and returns a new Promise that will
  # be resolved after the `fulfilledHandler` has been called.
  #
  # fulfilledHandler - The {Function} to call when the current promise
  #                    is fulfilled.
  # errorHandler - The {Function} to call when the current promise has been
  #                rejected.
  # progressHandler - The {Function} to call during the promise progress.
  #                   Note that not all the promise provides informations
  #                   about their progress.
  #
  # Returns a [Promise]{Promise}
  then: (fulfilledHandler, errorHandler, progressHandler) ->
    @start() unless @started
    promise = new Promise
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

  # Registers a callback for the rejection of the promise.
  # It's just an alias of:
  #
  # ```coffee
  # promise.then((->), errorHandler)
  # ```
  #
  # errorHandler - The {Function} to call when the current promise has been
  #                rejected.
  #
  # Returns a [Promise]{Promise}.
  fail: (errorHandler) -> @then (->), errorHandler

  # Binds the passed-in promise to this one so that the promise
  # is resolved when this promise resolved and hold the same value
  # or reason of the rejection.
  #
  # promise - The [Promise]{Promise} to bind to this promise resolution.
  #
  # Returns a [Promise]{Promise}.
  bind: (promise) ->
    @then ((res) -> promise.resolve(res)), ((reason) -> promise.reject(reason))

  # Resolves the current promise as fulfilled with the given `value`.
  #
  # value - The value to fulfill the promise with.
  resolve: (@value) ->
    return unless @pending

    @fulfilled = true
    @notifyHandlers()
    @pending = false

  # Resolves the current promise with a rejection.
  #
  # reason - The reason for the rejection.
  reject: (reason) ->
    return unless @pending

    @reason = reason
    @fulfilled = false
    @pending = false
    @notifyHandlers()

  # Starts the promise by calling its factory function if one was provided.
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

  # Setup a hook to reject the promise automatically after a given duration.
  #
  # timeout - The {Number} of milliseconds before the promise is rejected.
  # message - The message {String} to use for the rejection.
  rejectAfter: (@timeout, @message) ->

  ### Internal ###

  # Notifies the different callbacks registered on this promise according
  # to the promise state.
  notifyHandlers: ->
    if @fulfilled
      handler @value for handler in @fulfilledHandlers
    else
      handler @reason for handler in @errorHandlers

  # Returns the signature of the passed-in function.
  #
  # func - The {Function} for which return the signature.
  #
  # Returns an {Array} of the function arguments.
  signature: (func) ->
    re = ///
      ^function
      (\s+[a-zA-Z_][a-zA-Z0-9_]*)*
      \s*\(([^\)]+)\)
      ///
    re.exec(func.toString())?[2].split(/\s*,\s*/) or []
