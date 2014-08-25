{execute} = require './utils'

module.exports = (grunt) ->
  grunt.registerTask 'npm:test', 'Run npm tests', ->
    done = @async()
    execute('npm test')
    .then ->
      grunt.task.run 'growl:jasmine_success'
      done true
    .fail ->
      console.log 'in fail'
      grunt.task.run 'growl:jasmine_failure'
      done false

  grunt.registerTask 'npm:install', 'Run npm tests', ->
    done = @async()
    execute('npm install')
    .then ->
      console.log "Package installed #{'✓'.green}"
      done true
    .fail (reason) ->
      console.log reason
      done false
