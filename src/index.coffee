# The module bootstrap.
isCommonJS = typeof module isnt "undefined"

agt = {}

agt.mixins = mixins = {}
agt.random = random = {}
agt.geom = geom = {}
agt.particles = particles = {
  actions: {}
  emitters: {}
  timers: {}
  counters: {}
  initializers: {}
}

if isCommonJS
  exports = module.exports = agt
else
  exports = window.agt = agt

agt.CAMEL_CASE = 'camel'
agt.SNAKE_CASE = 'snake'
agt.COLORS =
  STROKE: '#ff0000'
  FILL: 'rgba(255,0,0,0.5)'
  VERTICES: '#0077ff'
  VERTICES_CONNECTIONS: 'rgba(0,127,255,0.5)'
  BOUNDING_BOX: '#69af23'

agt.deprecated = (message) ->
  parseLine = (line) ->
    if line.indexOf('@') > 0
      if line.indexOf('</') > 0
        [m, o, f] = /<\/([^@]+)@(.)+$/.exec line
      else
        [m, f] = /@(.)+$/.exec line
    else
      if line.indexOf('(') > 0
        [m, o, f] = /at\s+([^\s]+)\s*\(([^\)])+/.exec line
      else
        [m, f] = /at\s+([^\s]+)/.exec line

    [o,f]

  e = new Error()
  caller = ''
  if e.stack?
    s = e.stack.split('\n')
    [deprecatedMethodCallerName, deprecatedMethodCallerFile] = parseLine s[3]

    caller = if deprecatedMethodCallerName
      " (called from #{deprecatedMethodCallerName} at #{deprecatedMethodCallerFile})"
    else
       "(called from #{deprecatedMethodCallerFile})"

  console.log "DEPRECATION WARNING: #{message}#{caller}"
