'use strict';

require.config({
  shim: {
    howler: {
      exports: 'Howler'
    }
  },
  paths: {
    'jquery': '../bower_components/jquery/dist/jquery',
    'underscore': '../bower_components/underscore/underscore',
    'backbone': '../bower_components/backbone/backbone',
    // Waiting on this pull request:
    // https://github.com/goldfire/howler.js/pull/276
    // howler: 'bower_components/howler/src/howler.core',
    'howler': '../libs/howler.core',
    'text': '../bower_components/text/text',
    'jquery_ui': '../bower_components/jquery-ui/'
  }
});

require(['app']);