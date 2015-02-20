module.exports =
  domEvent: (type, data={}, options={bubbles, cancelable}={}) ->
    try
      event = new Event type, {
        bubbles: bubbles ? true
        cancelable: cancelable ? true
      }
    catch e
      if document.createEvent?
        event = document.createEvent 'Event'
        event.initEvent type, bubbles ? true, cancelable ? true
      else if document.createEventObject?
        event = document.createEventObject()
        event.type = type
        event[k] = v for k,v of options

    event.data = data
    event
