
# Public:
module.exports = 
class Animation
  constructor: (@image,
                @width, @height,
                @rowStart=0, @rowEnd=0,
                @colStart=0, @colEnd=0
                @durations) ->
    @durations = (1000 / 24 for i in [@colStart..@colEnd]) unless @durations?
    @rowLength = @rowEnd - @rowStart + 1
    @colLength = @colEnd - @colStart + 1
    @length = @rowLength * @colLength
