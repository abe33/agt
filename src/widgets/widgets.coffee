#
__widgets__ = {}

# The `__instances__` object stores the returned instances of the various widgets,
# stored by widget type and then mapped with their target DOM element as key.
__instances__ = {}

### Public ###

# The `widgets` function is both the main module and the function
# used to register the widgets to apply on a page.
widgets = agt.widgets = (name, selector, options={}, block) ->
  unless __widgets__[name]?
    throw new Error "Unable to find widget '#{name}'"

  # The options specific to the widget registration and activation are
  # extracted from the options object.
  events = options.on or 'init'
  ifCondition = options.if
  unlessCondition = options.unless
  mediaCondition = options.media

  delete options.on
  delete options.if
  delete options.unless
  delete options.media

  # Events can be passed as a string with event names separated with spaces.
  events = events.split /\s+/g if typeof events is 'string'

  # The widgets instances are stored in a Hash with the DOM element they
  # target as key. The instances hashes are stored per widget type.
  instances = __instances__[name] ||= new agt.widgets.Hash

  # This method execute a test condition for the given element. The condition
  # can be either a function or a value converted to boolean.
  testCondition = (condition, element) ->
    if typeof condition is 'function' then condition(element) else !!condition

  # The DOM elements handled by a widget will receive a handled class
  # to differenciate them from unhandled elements.
  handledClass = "#{name}-handled"

  # This method will test if an element can be handled by the current widget.
  # It will test for both the handled class presence and the widget
  # conditions. Note that if both the `if` and `unless` conditions
  # are passed in the options object they will be tested as both part
  # of a single `&&` condition.
  canBeHandled = (element) ->
    res = !element.classList.contains(handledClass)
    res &&= testCondition(ifCondition, element) if ifCondition?
    res &&= not testCondition(unlessCondition, element) if unlessCondition?
    res

  # If a media condition have been specified, the widget activation will be
  # conditionned based on the result of this condition. The condition is
  # verified each time the `resize` event is triggered.
  if mediaCondition?
    # The media condition can be either a boolean value, a function, or,
    # to simply the setup, an object with `min` and `max` property containing
    # the minimal and maximal window width where the widget is activated.
    if typeof mediaCondition is 'object'
      {min, max} = mediaCondition
      mediaCondition = ->
        res = true
        res &&= window.innerWidth >= min if min?
        res &&= window.innerWidth <= max if max?
        res

    # The media handler is registered on the `resize` event of the `window`
    # object.
    mediaHandler = (element, widget) ->
      return unless widget?

      condition_matched = testCondition(mediaCondition, element)

      if condition_matched and not widget.active
        widget.activate()
      else if not condition_matched and widget.active
        widget.deactivate()

    window.addEventListener 'resize', ->
      instances.eachPair (element, widget) ->
        mediaHandler element, widget

  # The `handler` function is the function registered on specified event and
  # will proceed to the creation of the widgets if the conditions are met.
  handler = ->
    elements = document.querySelectorAll selector

    Array::forEach.call elements, (element) ->
      return unless canBeHandled element

      widget = new agt.widgets.Widget(element)
      args = [widget, element, Object.create(options), elements]
      __widgets__[name].call(args...)
      element.classList.add handledClass
      instances.set element, widget

      # The widgets activation state are resolved at creation
      mediaHandler(element, res) if mediaCondition?

      document.dispatchEvent agt.domEvent("#{name}:handled", {element, widget})

      block?.call element, element, widget

  # For each event specified, the handler is registered as listener.
  # A special case is the `init` event that simply mean to trigger the
  # handler as soon a the function is called.
  events.forEach (event) ->
    switch event
      when 'init' then handler()
      when 'load', 'resize'
        window.addEventListener event, handler
      else
        document.addEventListener event, handler

# The `widgets.define` is used to create a new widget usable through the
# `widgets` method. Basically, a widget is defined using a `name`, and a
# `block` function that will be called for each DOM elements targeted by
# the widget.
#
# The `block` function should have the following signature:
#
#     function(element:HTMLElement, options:Object):Object
#
# The `options` object will contains all the options passed to the `widgets`
# method except the `on`, `if`, `unless` and `media` ones.
widgets.define = (name, block) -> __widgets__[name] = block

# A shorthand method to register a jQuery widget.
widgets.$define = (name, baseOptions={}, block) ->
  [baseOptions, block] = [{}, baseOptions] if typeof baseOptions is 'function'
  throw new Error "#{name} jquery widget isn't defined" unless $.fn[name]
  __widgets__[name] = (element, options={}) ->
    options[k] = v for k,v of baseOptions when not options[k]?
    res = $(element)[name](options)
    block?(res, options)

widgets.widgetsFor = (element, widget) ->
  if widget?
    __instances__[widget].get(element)
  else
    instances.get(element) for instances in __instances__ when instances.hasKey(element)

# The `widgets.release` method can be used to completely remove the widgets
# of the given `name` from the page.
# It's the widget responsibility to clean up its dependencies during
# the `dispose` call.
widgets.release = (names...) ->
  names = Object.keys(__instances__) if names.length is 0
  for name in names
    __instances__[name].each (value) -> value.dispose()

# Activates all the widgets instances of type `name`.
widgets.activate = (names...) ->
  names = Object.keys(__instances__) if names.length is 0
  for name in names
    __instances__[name].each (value) -> value.activate()

# Deactivates all the widgets instances of type `name`.
widgets.deactivate = (names...) ->
  names = Object.keys(__instances__) if names.length is 0
  for name in names
    __instances__[name].each (value) -> value.deactivate()

class agt.widgets.Widget
  @include agt.mixins.Activable
  @include agt.mixins.Disposable

  constructor: (@element) ->
