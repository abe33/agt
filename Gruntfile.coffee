{spawn, exec} = require 'child_process'
{print} = require 'util'
Q = require 'q'

run = (command) ->
  defer = Q.defer()
  [command, args...] = command.split(/\s+/g)
  exe = spawn command, args
  exe.stdout.on 'data', (data) -> print data
  exe.stderr.on 'data', (data) -> print data
  exe.on 'exit', (status) ->
    if status is 0 then defer.resolve(status) else defer.reject(status)
  defer.promise

module.exports = (grunt) ->
  grunt.initConfig

    ####     ######   #######  ######## ######## ######## ########
    ####    ##    ## ##     ## ##       ##       ##       ##
    ####    ##       ##     ## ##       ##       ##       ##
    ####    ##       ##     ## ######   ######   ######   ######
    ####    ##       ##     ## ##       ##       ##       ##
    ####    ##    ## ##     ## ##       ##       ##       ##
    ####     ######   #######  ##       ##       ######## ########
    coffee:
      glob_to_multiple:
        expand: true
        cwd: 'src/'
        src: ['**/*.coffee']
        dest: 'lib/'
        ext: '.js'

      build:
        options:
          join: true

        files:
          'build/agt.js': [
            'src/index.coffee'
            'src/object.coffee'
            'src/function.coffee'
            'src/inheritance.coffee'
            'src/math.coffee'
            'src/signal.coffee'
            'src/impulse.coffee'
            'src/promise.coffee'
            'src/mixins/*.coffee'
            'src/net/*.coffee'
            'src/random/**/*.coffee'
            'src/geom/mixins/**/*.coffee'
            'src/geom/point.coffee'
            'src/geom/triangle.coffee'
            'src/geom/rectangle.coffee'
            'src/geom/circle.coffee'
            'src/geom/**/*.coffee'
            'src/particles/particle.coffee'
            'src/particles/emission.coffee'
            'src/particles/system.coffee'
            'src/particles/sub_system.coffee'
            'src/particles/mixins/*.coffee'
            'src/particles/**/*.coffee'
            'src/widgets/widgets.coffee'
            'src/widgets/hash.coffee'
          ]

          'build/agt.spec.js': [
            'specs/support/spec_helper.coffee'
            'specs/support/**/*.coffee'
            'specs/units/**/*.coffee'
          ]

      demos:
        options:
          join: true

        files:
          'doc/assets/customs.js': [
            'demos/geometry_renderer.coffee'
            'demos/defaults.coffee'
            'demos/customs.coffee'
          ]

    uglify:
      all:
        files:
          'build/agt.min.js': ['build/agt.js']

    ####    ##      ##    ###    ########  ######  ##     ##
    ####    ##  ##  ##   ## ##      ##    ##    ## ##     ##
    ####    ##  ##  ##  ##   ##     ##    ##       ##     ##
    ####    ##  ##  ## ##     ##    ##    ##       #########
    ####    ##  ##  ## #########    ##    ##       ##     ##
    ####    ##  ##  ## ##     ##    ##    ##    ## ##     ##
    ####     ###  ###  ##     ##    ##     ######  ##     ##
    watch:
      scripts:
        files: ['src/**/*.coffee', 'specs/**/*.coffee']
        tasks: ['all']
        options:
          livereload: true
          livereloadOnError: true

      demos:
        files: ['demos/**/*.coffee', 'demos/**/*.css']
        tasks: ['biscotto', 'coffee:demos', 'extend:biscotto']

      config:
        files: ['Gruntfile.coffee']
        options:
          reload: true

    growl:
      jasmine_success:
        title: 'Jasmine Tests'
        message: 'All test passed'

      jasmine_failure:
        title: 'Jasmine Tests'
        message: 'Some tests failed'

      biscotto_success:
        title: 'Biscotto Documentation'
        message: 'Documentation generated'

  ####    ########    ###     ######  ##    ##  ######
  ####       ##      ## ##   ##    ## ##   ##  ##    ##
  ####       ##     ##   ##  ##       ##  ##   ##
  ####       ##    ##     ##  ######  #####     ######
  ####       ##    #########       ## ##  ##         ##
  ####       ##    ##     ## ##    ## ##   ##  ##    ##
  ####       ##    ##     ##  ######  ##    ##  ######
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-growl')

  grunt.registerTask 'extend:biscotto', 'Generates the documentation', ->
    done = @async()
    exec 'cat build/agt.min.js doc/assets/customs.js >> doc/assets/biscotto.js', (err, stdin, stderr) ->
      console.log stdin
      console.log stderr
      exec 'cat demos/customs.css >> doc/assets/biscotto.css', (err, stdin, stderr) ->
        console.log stdin
        console.log stderr
        grunt.task.run 'growl:biscotto_success'
        done()

  grunt.registerTask 'biscotto', 'Generates the documentation', ->
    done = @async()
    # run('biscotto src')
    run('/Users/cedric/Development/coffeescript/biscotto/bin/biscotto --internal --private -q src')
    .then ->
      done()
    .fail ->
      done()

  grunt.registerTask 'test', 'Run npm tests', ->
    done = @async()
    run('npm test')
    .then ->
      grunt.task.run 'growl:jasmine_success'
      done true
    .fail ->
      console.log 'in fail'
      grunt.task.run 'growl:jasmine_failure'
      done false

  grunt.registerTask('all', [
    'coffee:glob_to_multiple'
    'coffee:build'
    'uglify'
    'test'
    'biscotto'
    'coffee:demos'
    'extend:biscotto'
  ])
  grunt.registerTask('default', ['all'])
