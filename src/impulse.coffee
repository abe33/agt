
# Defines a local `requestAnimationFrame` function using the snippets
# from [Paul Irish](http://paulirish.com/2011/requestanimationframe-for-smart-animating/).
g = global ? window
requestAnimFrame = g.requestAnimationFrame       or
                   g.webkitRequestAnimationFrame or
                   g.mozRequestAnimationFrame    or
                   g.oRequestAnimationFrame      or
                   g.msRequestAnimationFrame     or
                   -> g.setTimeout callback, 1000 / 60

# Public: Impulse is a custom signal whose purpose is to handle
# animations within an application.
#
# The `Impulse` signal has its own messages to dispatch.
#
# Impulse dispatch its messages on a regular basis, based
# on the `requestAnimationFrame` function.
class agt.Impulse extends agt.Signal
  ### Public ###

  # Returns a global unique instance to use as reference
  # in a typical application
  #
  # Returns an {agt.Impulse}
  @instance: -> @__instance__ ||= new Impulse

  # Initialize the `Impulse` signal with a specific time scale.
  # By default the `timeScale` is `1`, which means there's no scaling.
  constructor:(@timeScale=1)->
    super()

    @running = false

  # Impulse listeners are registered as any other signal listeners.
  #
  # ```coffeescript
  # impulse.add (bias, biasInSeconds, time) ->
  # ```
  #
  # listener - The listener {Function} to register, with the following
  #            signature:
  #            :bias - The duration {Number} of the last animation
  #                    frame in milliseconds.
  #            :biasInSeconds - The duration {Number} of the last
  #                             animation frame in seconds.
  #            :time - The current time {Number} at the moment of the call.
  # context - The this {Object} for the listener.
  # priority - The priority {Number}, the greater the priority, the sooner
  #            the listener will be called.
  add:(listener, context, priority=0)->
    super listener, context, priority

    # By convention, the `Impulse` signal start running when the
    # first listener is added.
    @start() if @hasListeners() and not @running

  # Impulse listeners are unregistered as any other signal listeners.
  #
  # listener - The {Function} to remove from this signal.
  # context - The `this` {Object} that was registered with the listener.
  remove:(listener, context)->
    super listener, context

    # The `Impulse` object automatically stop itself when it doesn't
    # have a listener anymore.
    @stop() if @running and not @hasListeners()

  # {Delegates to: agt.Signal.hasListeners}
  hasListeners:->
    @listeners.length > 0

  # Starts, or restarts the `Impulse`.
  start:->
    @running = true
    @initRun()

  # Stops the `Impulse`.
  stop:->
    @running = false

  # Internal: Initializes the run of the `Impulse`. A request
  # is made to the `requestAnimationFrame` that will
  # call the `run` method each time.
  initRun:->
    @time = @getTime()
    requestAnimFrame =>
      @run()

  # A running `Impulse` will dispatch various informations
  # to its listeners each time the `run` method is called.
  #
  # The `initRun` is called at the end of the function if the impulse
  # is always running in order to continue the animation.
  run:->
    if @running
      t = @getTime()
      s = ( t - @time ) * @timeScale

      @dispatch s, s / 1000, t
      @initRun()

  # Internal: Helper method that return the current time.
  getTime:->
    new Date().getTime()
