namespace('agt.sprites')

class agt.sprites.Sprite
  constructor: (@animation) ->
    @position = new agt.geom.Point
    @center = new agt.geom.Point
    @frame = 0
    @time = 0

  animate: (bias) ->
    duration = @animation.durations[@frame]
    if @time > duration
      @frame = (@frame + 1) % @animation.length
      @time = @time % duration
    @time += bias

  render: (context) ->
    animation = @animation
    col = @frame % animation.colLength
    row = (@frame - col) / animation.colLength
    clipX = (animation.colStart + col) * animation.width
    clipY = (animation.rowStart + row) * animation.height

    x = @position.x - @center.x
    y = @position.y - @center.y

    context.drawImage animation.image,
                      clipX, clipY, animation.width, animation.height,
                      x, y, animation.width, animation.height
