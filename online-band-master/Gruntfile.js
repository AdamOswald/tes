'use strict';

module.exports = function(grunt) {
  require('time-grunt')(grunt);
  require('load-grunt-tasks')(grunt);

  grunt.initConfig({
    clean: ['app/dist'],
    jshint: {
      options: {
        jshintrc: '.jshintrc',
        reporter: require('jshint-stylish')
      },
      all: [
        'app/scripts/{,*/}*.js',
        'Gruntfile.js'
      ]
    },
    sass: {
      dev: {
        options: {
          style: 'expanded',
          sourcemap: 'none'
        },
        files: {
          'app/dist/app.css': 'app/styles/app.scss'
        }
      }
    },
    autoprefixer: {
      dist: {
        options: {
          browsers: ['last 100 versions']
        },
        files: [{
          expand: true,
          flatten: true,
          src: 'app/dist/*.css',
          dest: 'app/dist/'
        }]
      }
    },
    requirejs: {
      dist:{
        options: {
          baseUrl: 'app/scripts',
          mainConfigFile: 'app/scripts/main.js',
          name: '../bower_components/almond/almond',
          out: 'app/dist/app.js',
          include: 'main'
        }
      }
    },
    copy: {
      dist: {
        files: [
          {'app/dist/index.html': 'app/index-dist.html'},
          {'app/dist/categories.json': 'app/categories.json'},
          {
            expand: true,
            flatten: true,
            cwd: 'app/categories/',
            src: ['**'],
            dest: 'app/dist/categories/'
          },
          {
            expand: true,
            flatten: true,
            cwd: 'app/loops/',
            src: ['**'],
            dest: 'app/dist/loops/'
          }
        ]
      }
    },
    cssmin: {
      dist: {
        options: {
          keepSpecialComments: 0
        },
        files: [{
          src: [
            'app/bower_components/normalize.css/normalize.css',
            'app/dist/app.css',
            'app/bower_components/jquery-ui/themes/base/resizable.css',
            'app/bower_components/jquery-ui/themes/base/slider.css',
            'app/bower_components/icono/dist/icono.min.css'
          ],
          dest: 'app/dist/app.min.css'
        }]
      }
    },
    uglify: {
      dist: {
        files: {
          'app/dist/app.min.js': 'app/dist/app.js'
        }
      }
    },
    filerev: {
      options: {
        algorithm: 'md5',
        length: 8
      },
      dist: {
        src: ['app/dist/*.min*.js', 'app/dist/*.min*.css']
      }
    },
    usemin: {
      html: 'app/dist/index.html',
      options: {
        assetsDirs: 'app/dist'
      }
    },
    connect: {
      server: {
        options: {
          base: 'app',
          keepalive: true
        }
      }
    }
  });

  grunt.registerTask('default', [
    'jshint',
    'clean',
    'sass',
    'autoprefixer',
    'requirejs',
    'copy',
    'cssmin',
    'uglify',
    'filerev',
    'usemin'
  ]);
};