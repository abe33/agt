require './object'
require './function'
require './inheritance'
require './math'

window?.requestAnimationFrame = requestAnimationFrame or
                               webkitRequestAnimationFrame or
                               mozRequestAnimationFrame or
                               oRequestAnimationFrame or
                               msRequestAnimationFrame or
                               -> g.setTimeout callback, 1000 / 60
