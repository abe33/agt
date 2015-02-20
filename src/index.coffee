require './extensions'

module.exports =
  colors: require './colors'
  geom: require './geom'
  dom: require './dom'
  config: require './config'
  i18n: require './i18n'
  inflector: require './inflector'
  mixins: require './mixins'
  net: require './net'
  particles: require './particles'
  random: require './random'
  scenes: require './scenes'
  sprites: require './sprites'
  widgets: require './widgets'
  Signal: require './signal'
  Impulse: require './impulse'
  Promise: require './promise'
  deprecated: (message) ->
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
