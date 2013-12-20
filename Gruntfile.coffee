# Gruntfile

module.exports = (grunt) ->
  'use strict'
  require('load-grunt-tasks')(grunt)

  # Config variables
  config =
    build:      'build'
    www_port:   '9768'
    www_server: 'localhost'
    require:
      path: 'build/js/main.js'

  # Asset paths
  assets =
    coffee:
      src:    { path: 'assets/js',      ext: '.coffee'}
      dest:   { path: 'build/js',       ext: '.js'    }
    stylus:
      src:    { path: 'assets/css',     ext: '.styl'  }
      dest:   { path: 'build/css',      ext: '.css'   }
    jade:
      src:    { path: 'assets/views',   ext: '.jade'  }
      dest:   { path: 'build',          ext: '.html'  }


  # Build a files array that mapps to asset config values
  getAssetFiles = (target) ->
    files: [{
      expand:         true
      cwd:            assets[target].src.path
      src:  '**/*' +  assets[target].src.ext
      dest:           assets[target].dest.path
      ext:            assets[target].dest.ext
    }]


  grunt.initConfig
    # WATCH
    # Watch and compile app whenever changes are made.
    watch:
      options:
        nospawn: true
      jade:
        files:    assets.jade.src.path + '/**/*.jade'
        tasks:    ['clean:views', 'jade:all']
        options:  livereload: true
      coffee:
        files:    [assets.coffee.src.path + '/**/*.coffee']
        tasks:    ['coffeelint:app' ,'coffee:all', 'bower:app']
        options:  livereload: true
      stylus:
        files:    assets.stylus.src.path + '/**/*.styl'
        tasks:    ['stylus:all']
        options:  livereload: true
      gruntfile:
        files:    'Gruntfile.coffee'
        tasks:    ['coffeelint:gruntfile']


    # LINT
    coffeelint:
      app:        ['assets/**/*.coffee']
      rconf:      assets.coffee.src.path + '/main.coffee'
      gruntfile:  'Gruntfile.coffee'
      options:
        max_line_length:
          value: 160
          level: 'warn'



    # COMPILE
    # Compile Jade to HTML
    jade:
      all:        getAssetFiles 'jade'
      options:
        pretty:   true
        client:   false

    # Compile Stylus to CSS
    stylus:
      all:        getAssetFiles 'stylus'
      options:
        linenos:  true
        compress: false

    # Compile CoffeeScript
    coffee:
      all:        getAssetFiles 'coffee'
      rconf:
        src: assets.coffee.src.path + '/main.coffee'
        dest: config.require.path



    # UTILITIES
    # Reload dev server on source code change
    nodemon:
      dev:
        options:
          file: 'server.coffee'
          watchedExtensions: ['coffee']
          watchedFolders: ['server']
          delayTime: 0

    # Inject Bower packages into RequireJS config
    bower:
      app:
        rjsConfig: config.require.path

    # Remove precompile files
    clean:
      options:
        force: true
      js:       [ config.build + '/js' ]
      css:      [ config.build + '/css' ]
      images:   [ 'build/img']
      views:    [ config.build + '/pages', config.build + '/templates', config.build + '/index.html']
      build:    [ config.build ]

    # Copy files/folders
    copy:
      images:
        files: [{
          expand: true
          cwd:  'assets/img'
          src:  '**/*'
          dest: 'build/img'
        }]

    # Notification via Growl/OSX
    notify_hooks:
      options:
        enabled: true
        max_jshint_notifications: 5

    # Static server
    connect:
      options:
        hostname: config.www_server
        port:     config.www_port
        base:     './build'
      server:
        options:
          keepalive: true

    # Run tasks concurrently
    concurrent:
      dev:    ['watch', 'nodemon']
      clean:  ['clean:js', 'clean:css', 'clean:views', 'clean:images']
      build:  ['jade:all', 'stylus:all', 'coffee:all']
      options:
        logConcurrentOutput: true


  # TASKS
  grunt.registerTask  'server',         ['connect:server']
  grunt.registerTask  'clean-assets',   ['concurrent:clean']
  grunt.registerTask  'lint',           ['coffeelint:app']
  grunt.registerTask  'build',          ['clean-assets', 'lint', 'concurrent:build', 'bower', 'copy']
  grunt.registerTask  'dev',            ['notify_hooks', 'build', 'concurrent:dev']
  grunt.registerTask  'default',        ['dev']
  grunt.registerTask 'heroku:development', ['build']
