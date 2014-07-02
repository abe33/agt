# Public: Use a `Signal` object wherever you need to dispatch an event.
# A `Signal` is a dispatcher that have only one channel.
#
# Signals are generally defined as property of an object. And
# their name generally end with a past tense verb, such as in:
#
# ```coffeescript
# myObject.somethingChanged = new Signal
# ```
class agt.Signal

  ### Public ###

  # Creates a new `Signal` instance.
  # Optionally, a signal can have a specific signature.
  # A signature is a collection of argument names such:
  #
  # ```coffeescript
  # positionChanged = new Signal 'target', 'position'
  # ```
  #
  # If a signature is passed to a signal, every listener
  # added to the signal must then match the signature.
  #
  # ```coffeescript
  # # will be registered
  # positionChanged.add (target, position) ->
  #
  # # will be registered too
  # positionChanged.add (target, position, callback) ->
  #
  # # will not be registered
  # positionChanged.add () -> # will throw an error
  # ```
  #
  # In the case of an asynchronous listener, the callback argument
  # is not considered as being part of the signature.
  constructor: (@signature...) ->
    @listeners = []
    # The `asyncListeners` property stores the number of asynchronous
    # listeners to use a synchronous dispatch when equal to 0.
    @asyncListeners = 0

  # Registers a listener for this signal to be called with
  # the provided context.
  # The context is the object that can be accessed through `this`
  # inside the listener function body.
  #
  # An optional `priority` argument allow you to force
  # an order of dispatch for a listener.
  #
  # Signals listeners can be asynchronous, in that case the last
  # argument of the listener must be named `callback`. An async
  # listener blocks the dispatch loop until the callback function
  # passed to the listener is triggered.
  #
  # ```coffeescript
  # # sync listener
  # signal.add (a, b, c) ->
  #
  # # async listener
  # signal.add (a, b, c, callback) -> callback()
  # ```
  #
  # A listener can be registered several times, but only
  # if the context object is different each time.
  #
  # In other words, the following is possible:
  #
  # ```coffeescript
  # listener = ->
  # context = {}
  # myObject.signal.add listener
  # myObject.signal.add listener, context
  # ```
  #
  # When the following is not:
  #
  # ```coffeescript
  # listener = ->
  # myObject.signal.add listener
  # myObject.signal.add listener
  # ```
  #
  # listener - The {Function} to call when a signal is emitted.
  # context - The `this` {Object} to call the function with.
  # priority - A priority {Number}, the higher the priority the sooner
  #            the listener will be called in the dispatch loop.
  add: (listener, context, priority=0) ->
    @validate listener

    if not @registered listener, context
      @listeners.push [listener, context, false, priority]
      @asyncListeners++ if @isAsync listener

      # Listeners are sorted according to their order each time
      # a new listener is added.
      @sortListeners()

  # Registers a listener for only one call.
  #
  # All the others rules are the same. So you can't add
  # the same listener/context couple twice through the two methods.
  #
  # listener - The {Function} to call when a signal is emitted.
  # context - The `this` {Object} to call the function with.
  # priority - A priority {Number}, the higher the priority the sooner
  #            the listener will be called in the dispatch loop.
  addOnce: (listener, context, priority = 0) ->
    @validate listener
    if not @registered listener, context
      @listeners.push [listener, context, true, priority]
      @asyncListeners++ if @isAsync listener
      @sortListeners()

  # Removes a listener from this signal, but only with the context that
  # was registered with it.
  #
  # In this regards, avoid to register listeners without a context.
  # If later in the application a context is forgotten or invalid
  # when removing a listener from this signal, the listener
  # without context will end up being removed.
  #
  # listener - The {Function} to remove from this signal.
  # context - The `this` {Object} that was registered with the listener.
  remove: (listener, context) ->
    if @registered listener, context
      @asyncListeners-- if @isAsync listener
      @listeners.splice @indexOf(listener, context), 1

  # Removes all listeners at once.
  #
  # ```coffeescript
  # signal.removeAll()
  # ```
  removeAll: ->
    @listeners = []
    @asyncListeners = 0

  # Internal: `indexOf` returns the position of the listener/context couple
  # in the listeners array.
  indexOf: (listener, context) ->
    return i for [l,c],i in @listeners when listener is l and context is c
    -1

  # Returns true if the passed-in listener have been registered with the
  # specified context in this signal.
  #
  # listener - The listener {Function} to verify.
  # context - The context {Object} registered with the listener.
  #
  # Returns a {Boolean}.
  registered: (listener, context) ->
    @indexOf(listener, context) isnt -1

  # Returns true if the signal has listeners.
  #
  # Returns a {Boolean}.
  hasListeners: -> @listeners.length isnt 0

  # Internal: The listeners are sorted according to their `priority`.
  # The higher the priority the lower the listener will be
  # in the call order.
  sortListeners: ->
    return if @listeners.length <= 1
    @listeners.sort (a, b) ->
      [pA, pB] = [a[3], b[3]]

      if pA < pB then 1 else if pB < pA then -1 else 0

  # Internal: Throws an error if the passed-in listener's signature
  # doesn't match the signal's one.
  #
  # ```coffeescript
  # signal = new Signal 'a', 'b', 'c'
  # signal.validate () -> # false
  # signal.validate (a,b,c) -> # true
  # signal.validate (a,b,c,callback) -> # true
  # ```
  validate: (listener) ->
    if @signature.length > 0
      re = /[^(]+\(([^)]+)\).*$/m
      listenerSignature = Function::toString.call(listener).split('\n').shift()
      signature = listenerSignature.replace(re, '$1')
      args = signature.split /\s*,\s*/g

      args.shift() if args[0] is ''
      args.pop() if args[args.length-1] is 'callback'

      s1 = @signature.join()
      s2 = args.join()

      m = "The listener #{listener} doesn't match the signal's signature #{s1}"
      throw new Error m if s2 isnt s1

  # Returns `true` if the passed-in `listener` is asynchronous.
  #
  # ```coffeescript
  # signal.isAsync(->) # false
  # signal.isAsync((callback) ->) # true
  # ```
  #
  # listener - The listner {Function} to test.
  #
  # Returns a {Boolean}.
  isAsync: (listener) ->
    Function::toString.call(listener).indexOf('callback)') != -1

  # Dispatch a signal to the signal listeners.
  # Signals are dispatched to all the listeners. All the arguments
  # passed to the dispatch become the signal's message.
  #
  # ```coffeescript
  # signal.dispatch this, true
  # ```
  #
  # Listeners registered for only one call will be removed after
  # the call.
  #
  # Optionally you can pass a callback argument to the dispatch function.
  # In that case, the callback must be the last argument passed to the
  # `dispatch` function.  This function will be called at the end
  # of the dispatch, allowing to execute code after all listeners,
  # even asynchronous, have been triggered.
  #
  # ```coffeescript
  # signal.dispatch this, true, ->
  #     # all listeners have finish their execution
  # ```
  #
  # **Note:** As the dispatch function will automatically consider
  # the last argument as the callback if its type is `function`, you should
  # avoid using function as the sole argument or as the last argument
  # for a listener. If that case occurs, consider either re-arranging the
  # arguments order or using a value object to carry the function.
  #
  # args - The arguments to dispatch with the signal.
  # callback - A {Function} to callback when all listeners have been notified.
  dispatch: (args..., callback)->
    unless typeof callback is 'function'
      args.push callback
      callback = null

    listeners = @listeners.concat()
    # If at leat one listener is async, the whole dispatch process is async
    # otherwise the fast route is used.
    if @asyncListeners > 0
      next = (callback) =>
        if listeners.length
          [listener, context, once, priority] = listeners.shift()

          if @isAsync listener
            listener.apply context, args.concat =>
              @remove listener, context if once
              next callback
          else
            listener.apply context, args
            @remove listener, context if once
            next callback
        else
          callback?()

      next callback
    else
      # The fast route is just a loop over the listeners.
      # At that point, if your listener do async stuff, it will
      # not prevent the dispatching until it's done.
      for [listener, context, once, priority] in listeners
        listener.apply context, arguments
        @remove listener, context if once

      callback?()
