define([
  'jquery',
  'underscore',
  'backbone'
],

function ($, _, Backbone) {
  'use strict';

  return Backbone.Model.extend({
    urlRoot: 'categories',
    parse: function (loops) {
      return {
        loops: loops
      };
    }
  });
});