
module.exports =
  MULTIPLY: (v1, v2) ->
    v1 * v2 / 255

  SCREEN: (v1, v2) ->
    v1 + v2 - (v1 * v2 / 255)

  OVERLAY: (v1, v2) ->
    if v2 < 128 then 2 * v1 * v2 / 255 else 255 - (2 * (255 - v1) * (255 - v2) / 255)

  SOFT_LIGHT: (v1, v2) ->
    if v1 > 127.5
      v2 + (255 - v2) * (v1 - 127.5) / 127.5 * (0.5 - (Math.abs(v2 - 127.5) / 255))
    else
      v2 - v2 * (127.5 - v1) / 127.5 * (0.5 - (Math.abs(v2 - 127.5) / 255))

  HARD_LIGHT: (v1, v2) ->
    if v1 > 127.5
      v2 + (255 - v2) * (v1 - 127.5) / 127.5
    else
      v2 * v1 / 127.5

  COLOR_DODGE: (v1, v2) ->
    if v1 == 255 then v1 else Math.min(255, (v2 << 8) / (255 - v1))

  COLOR_BURN: (v1, v2) ->
    if v1 == 0 then v1 else Math.max(0, 255 - ((255 - v2 << 8) / v1))

  LINEAR_COLOR_DODGE: (v1, v2) ->
    Math.min v1 + v2, 255

  LINEAR_COLOR_BURN: (v1, v2) ->
    if v1 + v2 < 255 then 0 else v1 + v2 - 255
