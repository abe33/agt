namespace('agt.sprites')

class agt.sprites.Renderer
  constructor: (@context) ->
    @sprites = []

  render: ->
    sprite.render(context) for sprite in @sprites
