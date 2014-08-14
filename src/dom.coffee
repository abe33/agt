agt.domEvent = (type, data={}, options={bubbles, cancelable}={}) ->
  try
    event = new Event type, {
      bubbles: bubbles ? true
      cancelable: cancelable ? true
    }
  catch e
    event = document.createEvent 'Event'
    event.initEvent type, bubbles ? true, cancelable ? true

  event.data = data
  event
