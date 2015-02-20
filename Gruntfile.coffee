
npm = require './tasks/npm'
biscotto = require './tasks/biscotto'
gemify = require './tasks/gemify'
remapify = require 'remapify'

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

    browserify:
      lib:
        options:
          transform: ['coffeeify']
          browserifyOptions:
            extensions: ['.coffee']
        files:
          'build/agt.js': [
            'src/**/*.coffee'
          ]
          'build/agt.spec.js': [
            'specs/support/spec_helper.coffee'
            'specs/support/**/*.coffee'
            'specs/units/**/*.coffee'
          ]

      demos:
        options:
          transform: ['coffeeify']
          browserifyOptions:
            extensions: ['.coffee']
          preBundleCB: (b) ->
            b.plugin(remapify, [
              {
                cwd: __dirname
                src: './lib/**/*.js'
                expose: 'agt'
                filter: (alias, dirname, basename) ->
                  alias = alias
                  .replace(/\/lib\//, '/')
                  .replace(/\/index\.js$/, '')
                  .replace(/\.js$/, '')
                  alias
              }
            ])

        files:
          'demos/build/assets/js/camera.js': ['demos/assets/js/camera.coffee']
          'demos/build/assets/js/particles.js': ['demos/assets/js/particles.coffee']
          'demos/build/assets/js/forms.js': ['demos/assets/js/forms.coffee']

    ####     ######  ######## ##    ## ##       ##     ##  ######
    ####    ##    ##    ##     ##  ##  ##       ##     ## ##    ##
    ####    ##          ##      ####   ##       ##     ## ##
    ####     ######     ##       ##    ##       ##     ##  ######
    ####          ##    ##       ##    ##       ##     ##       ##
    ####    ##    ##    ##       ##    ##       ##     ## ##    ##
    ####     ######     ##       ##    ########  #######   ######
    stylus:
      build:
        options:
          compress: true
          paths: ['demos/assets/css/partials']
        files:
          'demos/build/assets/css/index.css': [
            'demos/assets/css/index.styl'
          ]

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

      stylus:
        files: ['demos/assets/css/**/*.styl']
        tasks: ['stylus']
        options:
          livereload: true
          livereloadOnError: false

      demos:
        files: ['demos/**/*.coffee']
        tasks: ['biscotto', 'coffee:docs', 'browserify:demos', 'extend:biscotto']

      config:
        files: ['Gruntfile.coffee', 'tasks/*.coffee']
        options:
          reload: true

      npm:
        files: ['package.json']
        tasks: ['npm:install']

    ####     ######   ########   #######  ##      ## ##
    ####    ##    ##  ##     ## ##     ## ##  ##  ## ##
    ####    ##        ##     ## ##     ## ##  ##  ## ##
    ####    ##   #### ########  ##     ## ##  ##  ## ##
    ####    ##    ##  ##   ##   ##     ## ##  ##  ## ##
    ####    ##    ##  ##    ##  ##     ## ##  ##  ## ##
    ####     ######   ##     ##  #######   ###  ###  ########
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
  grunt.loadNpmTasks('grunt-contrib-stylus')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.loadNpmTasks('grunt-growl')

  npm(grunt)
  biscotto(grunt)
  gemify(grunt)

  grunt.registerTask('all', [
    'coffee:lib'
    'browserify:lib'
    'uglify'
    'stylus'
    'npm:test'
    'biscotto'
    'browserify:demos'
    'coffee:docs'
    'extend:biscotto'
    'gemify:prepare'
  ])
  grunt.registerTask('default', ['all'])
