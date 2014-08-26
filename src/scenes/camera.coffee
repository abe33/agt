namespace('agt.scenes')

{Rectangle, Range} = agt.geom

CAMERA_SETTERS_MAP =
  x: 'moveToX'
  y: 'moveToY'
  width: 'resizeToWidth'
  height: 'resizeToHeight'

class agt.scenes.Camera
  @include agt.mixins.Emitter

  constructor: (@screen=new Rectangle(0, 0,
                                      window.innerWidth, window.innerHeight),
                @initialZoom=1,
                @zoomRange=new Range(-Infinity, Infinity),
                @silent=false) ->

  Object.keys(CAMERA_SETTERS_MAP).forEach (key) ->
    setter = CAMERA_SETTERS_MAP[key]

    Camera.accessor key, {
      get: -> @screen[key]
      set: (value) -> @[setter](value)
    }

    Camera::[setter] = (value) ->
      @screen[key] = value
      @dispatch('changed', this) unless @inBatch

  update: (props={}) ->
    @inBatch = true
    changed = false
    for key, value of props
      @[key] = value
      changed ||= true
    
    @dispatch('changed', this) if changed
    @inBatch = false
