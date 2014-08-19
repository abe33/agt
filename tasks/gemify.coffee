Q = require 'q'
path = require 'path'
{run} = require './utils'


module.exports = (grunt) ->

  exec_template = (template, locals) ->
    template.replace /\{\{([^}]+)\}\}/g, (_, key) -> locals[key]

  copy_template = (from, to, locals) ->
    Q.fcall ->
      template = grunt.file.read(from)
      content = exec_template(template, locals)

      grunt.file.write to, content

  copy_dir = (from, to, locals) ->
    promises = []
    grunt.file.recurse from, (abspath, rootdir, subdir, filename) ->
      if subdir?
        outdir = "#{to}/#{subdir}/#{filename}"
      else
        outdir = "#{to}/#{filename}"

      promises.push copy_template(abspath, outdir, locals)

    Q.all(promises)

  grunt.registerTask 'gemify:prepare', 'Generates the assets gem', ->
    done = @async()
    locals = require('../package.json')
    [author, email] = locals.author[0..-2].split(' <')
    locals.author = author
    locals.email = email
    locals.repository = locals.repository.url

    run('rm -rf gem/*')
    .then ->
      grunt.file.mkdir 'gem/app/assets/javascripts/agt'

      copy_dir('tasks/gemify', 'gem', locals)
    .then ->
      run('cp -R src/* gem/app/assets/javascripts/agt')
    .then ->
      run('cp -R *.md gem/')
    .then ->
      done()

  grunt.registerTask 'gemify:build', 'Generates the assets gem', ->
    done = @async()

    run("rake build --trace", cwd: path.resolve('./gem')).then -> done()

  grunt.registerTask 'gemify:publish', 'Publish the gem on rubygems', ->
    done = @async()
    gem = grunt.file.expand('gem/pkg/*.gem')[0].replace 'gem/', ''
    run("gem push #{gem}", cwd: path.resolve('./gem')).then -> done()
