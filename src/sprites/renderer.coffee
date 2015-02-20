module.exports =
class Renderer
  constructor: (@context) ->
    @sprites = []

  render: ->
    sprite.render(context) for sprite in @sprites
