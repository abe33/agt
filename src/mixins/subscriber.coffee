namespace('agt.mixins')

class agt.mixins.Subscriber
  subscribe: (emitter, event, options={}, listener) ->
    [listener, options] = [options, {}] if typeof options is 'function'

    @subscripions ?= {}
    @subscripions[event] ?= []

    subscription = emitter.on(event, options, listener)
    subscription.emitter = emitter
    subscription.listener = listener
    subscription.event = event

    @subscripions[event].push(subscription)
    subscription

  unsubscribe: (emitter, event, options={}, listener) ->
    [listener, options] = [options, {}] if typeof options is 'function'

    if emitter?
      if event?
        if listener?
          @filterSubscriptions event, (subscription) =>
            match = subscription.listener is listener and
                    subscription.emitter is emitter
            subscription.off() if match
            not match

        else
          @filterSubscriptions event, (subscription) =>
            match = subscription.emitter is emitter
            subscription.off() if match
            not match

      else
        @filterSubscriptions (subscription) =>
          match = subscription.emitter is emitter
          subscription.off() if match
          not match

    else
      @filterSubscriptions (subscription) =>
        subscription.off()
        true


  filterSubscriptions: (event, block) ->
    [block, event] = [event, null] if typeof event is 'function'

    if event? and @subscripions[event]?
      newSubscriptions = []

      for subscription in @subscripions[event]
        unless block(subscription)
          newSubscriptions.push(subscription)

      @subscripions[event] = newSubscriptions

    else unless event?
      newSubscriptions = {}

      for event, subscripions of @subscripions
        for subscription in subscripions
          unless block(subscription)
            newSubscriptions[event] ?= []
            newSubscriptions[event].push(subscription)

      @subscripions = newSubscriptions
