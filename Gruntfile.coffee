
npm = require './tasks/npm'
biscotto = require './tasks/biscotto'
gemify = require './tasks/gemify'

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
      lib:
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
            'src/config.coffee'
            'src/object.coffee'
            'src/function.coffee'
            'src/inheritance.coffee'
            'src/math.coffee'
            'src/signal.coffee'
            'src/impulse.coffee'
            'src/promise.coffee'
            'src/dom.coffee'
            'src/mixins/*.coffee'
            'src/net/*.coffee'
            'src/inflector/inflector.coffee'
            'src/inflector/*.coffee'
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
            'src/scenes/**/*.coffee'
            'src/sprites/**/*.coffee'
            'src/widgets/widgets.coffee'
            'src/widgets/hash.coffee'
            'src/widgets/widgets/*.coffee'
          ]

          'build/agt.spec.js': [
            'specs/support/spec_helper.coffee'
            'specs/support/**/*.coffee'
            'specs/units/**/*.coffee'
          ]

      docs:
        options:
          join: true

        files:
          'doc/assets/index.js': [
            'demos/docs/geometry_renderer.coffee'
            'demos/docs/defaults.coffee'
            'demos/docs/index.coffee'
          ]

      demos:
        expand: true
        cwd: 'demos/'
        src: ['assets/**/*.coffee']
        dest: 'demos/build'
        ext: '.js'

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
        tasks: ['biscotto', 'coffee:docs', 'coffee:demos', 'extend:biscotto']

      config:
        files: ['Gruntfile.coffee', 'tasks/*.coffee']
        options:
          reload: true

      npm:
        files: ['package.json']
        tasks: ['npm:install']

    growl:
      jasmine_success:
        title: 'Jasmine Tests'
        message: 'All tests passed'

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

  npm(grunt)
  biscotto(grunt)
  gemify(grunt)

  grunt.registerTask('all', [
    'coffee:lib'
    'coffee:build'
    'uglify'
    'npm:test'
    'biscotto'
    'coffee:demos'
    'coffee:docs'
    'extend:biscotto'
    'gemify:prepare'
  ])
  grunt.registerTask('default', ['all'])
