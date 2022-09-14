define([
  'underscore',
  'backbone',
  '../util/drag_drop_helper',
  '../util/constants'
],

function (_, Backbone, dragDropHelper, constants) {
  'use strict';

  var InfoView = Backbone.View.extend({
    template: function () {
      return '<div class="track-name">Track</div>';
    },
    className: 'track-info',
    render: function () {
      this.$el.html(this.template());
      return this;
    }
  });

  var LoopsView = Backbone.View.extend({
    className: 'track',
    render: function () {
      dragDropHelper.applyTracksPaneDroppable(this.$el);
      return this;
    }
  });

  return Backbone.View.extend({
    initialize: function () {
      this.infoView = new InfoView().render();
      this.loopsView = new LoopsView().render();
      this.loopViews = {};
    },
    addLoop: function (loopPlayerView, id) {
      if (!id) {
        id = loopPlayerView.$el.attr('id');
        var width = loopPlayerView.duration*constants.pixelsPerSecond;
        this.loopsView.$el.append(loopPlayerView.$el);
        loopPlayerView.$el.width(width).addClass('track-loop');
        loopPlayerView.render();
      }
      this.loopViews[id] = loopPlayerView;
    },
    removeLoop: function (id) {
      var loopPlayerView = this.loopViews[id];
      delete this.loopViews[id];
      return loopPlayerView;
    },
    isPlayable: function () {
      return !_.some(this.loopViews, function (loopPlayerView) {
        return !loopPlayerView.loaded;
      });
    },
    getLoops: function () {
      return _.values(this.loopViews);
    }
  });
});