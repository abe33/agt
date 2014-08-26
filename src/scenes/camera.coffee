namespace('agt.scenes')

{Rectangle, Range} = agt.geom

class agt.scenes.Camera
  @include agt.mixins.Emitter

  constructor: (@screen=new Rectangle(0, 0,
                                      window.innerWidth, window.innerHeight),
                @initialZoom=1,
                @zoomRange=new Range(-Infinity, Infinity),
                @silent=false) ->


  @accessor 'x',
    get: -> @screen.x
    set: (value) ->
      @screen.x = value
      @fireCameraChange()

  @accessor 'y',
    get: -> @screen.y
    set: (value) ->
      @screen.y = value
      @fireCameraChange()

  @accessor 'width',
    get: -> @screen.width
    set: (value) ->
      @screen.width = value
      @fireCameraChange()

  @accessor 'height',
    get: -> @screen.height
    set: (value) ->
      @screen.height = value
      @fireCameraChange()

  @accessor 'rotation',
    get: -> @screen.rotation
    set: (value) ->
      @screen.rotateAroundCenter(rotation - @screen.rotation)
      @fireCameraChange()

  @accessor 'zoom',
    get: -> @_zoom
    set: (value) ->
      if @zoomRange.surround(value)
        @_zoom = value

  update: (props={}) ->
    @inBatch = true
    changed = false
    for key, value of props
      @[key] = value
      changed ||= true

    @dispatch('changed', this) if changed
    @inBatch = false

  fireCameraChange: -> @dispatch('changed', this) unless @inBatch
