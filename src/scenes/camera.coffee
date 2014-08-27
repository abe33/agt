namespace('agt.scenes')

{Rectangle, Range} = agt.geom

class agt.scenes.Camera
  @include agt.mixins.Emitter

  constructor: (@screen=new Rectangle(0, 0,
                                      window.innerWidth, window.innerHeight),
                @_zoom=1,
                @zoomRange=new Range(-Infinity, Infinity),
                @silent=false) ->
    @_width = @screen.width
    @_height = @screen.height


  @accessor 'x',
    get: -> @screen.center().x
    set: (value) ->
      return if value is @x
      @screen.setCenter(value, @y)
      @fireCameraChange()

  @accessor 'y',
    get: -> @screen.center().y
    set: (value) ->
      return if value is @y
      @screen.setCenter(@x, value)
      @fireCameraChange()

  @accessor 'width',
    get: -> @_width
    set: (value) ->
      return if value is @_width
      @_width = value
      @updateZoom()

  @accessor 'height',
    get: -> @_height
    set: (value) ->
      return if value is @_height
      @_height = value
      @updateZoom()

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
        @updateZoom()

  update: (props={}) ->
    @inBatch = true
    changed = false
    for key, value of props
      @[key] = value
      changed ||= true

    @dispatch('changed', this) if changed
    @inBatch = false

  updateZoom: ->
    center = @screen.center()
    @screen.width = @_width * @_zoom
    @screen.height = @_height * @_zoom
    @screen.setCenter(center)
    @fireCameraChange()

  fireCameraChange: -> @dispatch('changed', this) unless @inBatch
