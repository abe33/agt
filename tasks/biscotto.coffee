{run} = require './utils'

module.exports = (grunt) ->
  grunt.registerTask 'biscotto', 'Generates the documentation', ->
    done = @async()
    # run('biscotto src')
    run('/Users/cedric/Development/coffeescript/biscotto/bin/biscotto --internal --private -q src')
    .then ->
      done()

  grunt.registerTask 'extend:biscotto', 'Generates the documentation', ->
    done = @async()

    run('cat build/agt.min.js doc/assets/customs.js >> doc/assets/biscotto.js')
    .then ->
      run('cat demos/customs.css >> doc/assets/biscotto.css')
    .then ->
      grunt.task.run 'growl:biscotto_success'
      done()
