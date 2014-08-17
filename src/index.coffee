# The module bootstrap.
isCommonJS = typeof module isnt "undefined"

__namespaces__ = {}

namespace = (path) ->
  return if __namespaces__[path]

  __namespaces__[path] = true

  originalPath = path
  path = path.split('.')
  root = path.shift()

  obj = if isCommonJS
    module.exports
  else
    window[root] ||= {}

  for p in path
    obj = obj[p] = obj[p] or {}

namespace('agt')

if isCommonJS
  agt = module.exports
else
  agt = window.agt

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
