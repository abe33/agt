
module.exports =
class Emitter

  dispatch: (event, data) ->
    @listeners?[event]?.forEach (listener) -> listener(data)

  on: (event, options={}, listener) ->
    [listener, options] = [options, {}] if typeof options is 'function'
    @listeners ?= {}
    @listeners[event] ?= []

    @listeners[event].push(listener) unless listener in @listeners[event]
    off: => @off(event, options, listener)

  once: (event, options={}, listener) ->
    [listener, options] = [options, {}] if typeof options is 'function'

    subscription = @on event, options, (data) =>
      listener(data)
      subscription.off()

  off: (event, options={}, listener) ->
    [listener, options] = [options, {}] if typeof options is 'function'

    if event?
      if listener?
        if @listeners?[event]? and listener in @listeners[event]
          @listeners[event].splice(@listeners[event].indexOf(listener))
      else
        @listeners[event] = []
    else
      @listeners = {}

  hasListeners: (event) ->
    if event?
      @listeners?[event].length > 0
    else
      if @listeners?
        Object.keys(@listeners).some (event) => @hasListeners(event)
      else
        false
