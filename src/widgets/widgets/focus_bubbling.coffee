module.exports = (widgets) ->
  # Public: This widgets decorates all the dom path until the current
  # element with a `focus` class when the element have the focus.
  widgets.define 'bubbling_focus', (element) ->
    blur = ->
      Array::forEach.call document.querySelectorAll('.focus'), (el) ->
        el.classList.remove('.focus')

    element.addEventListener 'blur', -> blur()
    element.addEventListener 'focus', ->
      blur()
      node = element
      node.classList.add('focus')
      while node.nodeName.toLowerCase() isnt 'html'
        node = node.parentNode
        node.classList.add('focus')
