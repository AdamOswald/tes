define([
  'backbone',
  'jquery',
  'underscore',
  './track',
  './loop_player',
  '../util/drag_drop_helper',
  '../util/loop_helper',
  '../util/constants',
  'text!../../templates/tracks_pane.html',
  'jquery_ui/ui/droppable',
  'jquery_ui/ui/resizable'
],

function (Backbone, $, _, TrackView, LoopPlayerView, dragDropHelper, loopHelper, constants, Template) {
  'use strict';

  return Backbone.View.extend({
    template: _.template(Template),
    events: {
      'click .add-track': 'addTrack'
    },
    trackViews: [],
    initialize: function () {
      this.listenTo(dragDropHelper.events, 'new', this.addLoop);
      this.listenTo(dragDropHelper.events, 'move', this.moveLoop);
    },
    addLoop: function (meta) {
      var trackView = this.trackViews[meta.trackIndex];
      var loopPlayerView = new LoopPlayerView(meta.loopData);
      loopPlayerView.$el.css({left: meta.left, top: 0});
      trackView.addLoop(loopPlayerView);
      this.resizeTracks(meta.trackIndex, loopPlayerView);
    },
    moveLoop: function (meta) {
      var trackView = this.trackViews[meta.prevTrackIndex];
      var loopPlayerView = trackView.removeLoop(meta.id);
      this.trackViews[meta.trackIndex].addLoop(loopPlayerView, meta.id);
      this.resizeTracks(meta.trackIndex, loopPlayerView);
    },
    resizeTracks: function (trackIndex, loopPlayerView) {
      var trackWidth = this.trackViews[trackIndex].loopsView.$el.width();
      var rightPosition = loopHelper.right(loopPlayerView.$el);
      if (Math.abs(trackWidth-rightPosition) < constants.pixelsBeforeResize) {
        this.$('.track').width(trackWidth*constants.resizeFactor);
      }
    },
    addTrack: function () {
      // Create a new track
      var trackView = new TrackView();
      // Append the track
      trackView.infoView.$el.insertBefore(this.$('.add-track'));
      this.$('.loops').append(trackView.loopsView.$el);
      // Increase height of seeker
      var $seeker = this.$('.seeker');
      $seeker.height($seeker.height() + trackView.loopsView.$el.height());
      this.trackViews.push(trackView);
    },
    isPlayable: function () {
      var numLoops = 0;

      for (var i=0; i<this.trackViews.length; i++) {
        var trackView = this.trackViews[i];
        if (!trackView.isPlayable()) {
          return false;
        }
        numLoops += trackView.getLoops().length;
      }

      return numLoops > 0;
    },
    getLoopChain: function (allLoops, index) {
      var chain = [index];
      var right = allLoops[index].getRight();

      // TODO: use binary search
      var connectedLoops = [];
      _.each(allLoops, function (currentLoop, i) {
        if (currentLoop.getLeft() === right) {
          connectedLoops.push(i);
        }
      });

      if (connectedLoops.length) {
        _.each(connectedLoops, function (connectedLoop) {
          chain.push.apply(chain, this.getLoopChain(allLoops, connectedLoop));
        }, this);
      }

      return chain;
    },
    attachStartHandler: function (loops, index) {
      var currentLoop = loops[index];
      currentLoop.howler.once('end', function () {
        for (var i=index+1; i<loops.length; i++) {
          var nextLoop = loops[i];
          if (nextLoop && currentLoop.getRight() === nextLoop.getLeft()) {
            // Play from beginning
            nextLoop.seek(0).play();
          }
        }
      });
    },
    play: function () {
      if (!this.isPlayable()) {
        // TODO: better handling
        window.alert('Please try again when the audios are loaded');
        return;
      }

      // Reset seeker
      var $seeker = this.$('.seeker').stop().css('left', 0);
      
      // Get all the loops
      var allLoops = [];
      _.each(this.trackViews, function (trackView) {
        allLoops.push.apply(allLoops, trackView.getLoops());
      });
      
      // Sort loops by their left position
      allLoops.sort(function (a, b) {
        return a.getLeft() > b.getLeft();
      });

      // Find the last loop that will be played
      var length = _.max(allLoops, function (loopPlayerView) {
        return loopPlayerView.getRight();
      }).getRight();

      // Populate the list of "chains". A chain is a series of
      // loops that are back to back.
      var chains = [];
      while (allLoops.length) {
        var loopChain = this.getLoopChain(allLoops, 0);
        
        // Loop from the end so removing from array won't mess
        // up the indexes
        for (var i=loopChain.length-1; i>=0; i--) {
          var index = loopChain[i];
          loopChain[i] = allLoops[index];
          allLoops.splice(index, 1);
          this.attachStartHandler(loopChain, i);
        }

        var prevStartTime = chains.length? _.last(chains).chain[0].getStart() : 0;
        chains.push({
          waitTime: (loopChain[0].getStart() - prevStartTime) * 1000,
          chain: loopChain
        });
      }

      $seeker.animate({left: length}, {
        easing: 'linear',
        duration: length / (constants.pixelsPerSecond / 1000),
        start: function playChain () {
          var currentChain = chains.shift();
          if (currentChain) {
            setTimeout(function () {
              currentChain.chain[0].seek(0).play();
              playChain();
            }, currentChain.waitTime);
          }
        }
      });
    },
    syncScrollbars: function () {
      var self = this;
      this.$('.loops').scroll(function () { 
        self.$('.tracks').scrollTop($(this).scrollTop());
      });
    },
    initializeSeeker: function () {
      var $seeker = this.$('.seeker');
      $seeker.draggable({
        axis: 'x',
        containment: 'parent'
      });
    },
    render: function () {
      this.$el.html(this.template());
      this.syncScrollbars();
      this.initializeSeeker();
      return this;
    }
  });
});