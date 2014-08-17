# Public: Decorates an input that support the `checked` property with
# a `checked` class whenever its property is `true`. It allows to have
# css rules on checked input on IE versions that doesn't support
# the `:checked` selector.
agt.widgets.define 'checked_input', (element) ->
  element.addEventListener 'change', ->
    element.classList.toggle 'checked', element.checked
