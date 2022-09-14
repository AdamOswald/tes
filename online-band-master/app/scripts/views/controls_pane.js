define([
  'backbone',
  'jquery',
  'underscore',
  'text!../../templates/controls_pane.html'
],

function (Backbone, $, _, template) {
  'use strict';

  return Backbone.View.extend({
    events: {
      'click .play-button': 'play'
    },
    play: function () {
      // TODO: change button ui
      this.trigger('play');
    },
    render: function () {
      this.$el.html(template);
      return this;
    }
  });
});