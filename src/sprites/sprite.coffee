Point = require '../geom/point'
# Public:
module.exports =
class Sprite
  constructor: (@animation) ->
    @position = new Point
    @center = new Point
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
