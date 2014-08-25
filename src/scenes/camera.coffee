namespace('agt.scenes')

propertiesMapping =
  x: 'moveToX'
  y: 'moveToY'
  width: 'resizeToWidth'
  height: 'resizeToHeight'

class agt.scenes.Camera


  constructor: (@screen=new agt.geom.Rectangle(0,0,window.innerWidth, window.innerHeight), @initialZoom=1, @zoomRange=new agt.geom.Range(-Infinity, Infinity), @silent=false) ->

  Object.keys(propertiesMapping).forEach (key) ->
    setter = propertiesMapping[key]
    Camera.accessor key, {
      get: -> @screen[key]
      set: (value) -> @[setter](value)
    }

    Camera::[setter] = (value) ->
      @screen[key] = value
