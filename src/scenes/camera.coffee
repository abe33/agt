namespace('agt.scenes')

{Rectangle, Range} = agt.geom

CAMERA_SETTERS_MAP =
  x: 'moveToX'
  y: 'moveToY'
  width: 'resizeToWidth'
  height: 'resizeToHeight'

class agt.scenes.Camera
  constructor: (@screen=new Rectangle(0, 0,
                                      window.innerWidth, window.innerHeight),
                @initialZoom=1,
                @zoomRange=new Range(-Infinity, Infinity),
                @silent=false) ->
    @changed = new agt.Signal

  Object.keys(CAMERA_SETTERS_MAP).forEach (key) ->
    setter = CAMERA_SETTERS_MAP[key]

    Camera.accessor key, {
      get: -> @screen[key]
      set: (value) -> @[setter](value)
    }

    Camera::[setter] = (value) ->
      @screen[key] = value
      @changed.dispatch(this)
