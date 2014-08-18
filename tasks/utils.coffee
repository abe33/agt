{exec} = require 'child_process'
{print} = require 'util'
Q = require 'q'

module.exports =
  run: (command) ->
    defer = Q.defer()

    exec command, (err, stdout, stderr) ->
      if err?
        print stderr
        defer.reject(err)
      else
        print stdout
        defer.resolve()

    defer.promise
