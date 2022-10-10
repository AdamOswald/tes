define([
  'jquery',
  'underscore',
  'backbone',
  './loop_helper',
  './constants'
],

function ($, _, Backbone, loopHelper, constants) {
  'use strict';

  // Make use of backbone events
  var events = _.extend({}, Backbone.Events);

  /**
   * Check whether or not the loop can be dropped into the
   * current track by checking for collisions.
   * @param  {$object}  $track current track
   * @param  {$object}  $loop current loop
   * @return {boolean} whether or not it has collision
   */
  function hasCollision ($track, $loop) {
    var collision = false;
    var width = $loop.outerWidth();
    var left = loopHelper.left($loop);
    var right = loopHelper.right($loop);

    // Too far left, overlapping with the tracks. Let's just move it
    // to the front for them
    if (left < 0) {
      left = 0;
      right = width;
      $loop.css('left', 0);
    }

    // See if the current position collides with anything in the track
    $track.find('.track-loop').each(function () {
      var $this = $(this);
      // Don't compare itself
      if (!$this.is($loop)) {
        var currentLeft = loopHelper.left($this);
        var currentRight = loopHelper.right($this);
        if ((currentLeft < left && currentRight > left) ||
          (currentLeft > left && currentLeft < right)) {
          collision = true;
          return; // break out of loop
        }
      }
    });
    return collision;
  }

  /**
   * Allow the loops to be dragged to the tracks
   * pane.
   * @param  {$object} $elems elements to make draggable
   */
  function applyLoopsPaneDraggable ($elems) {
    $elems.draggable({
      appendTo: '.loops',
      scroll: false, // prevent scrolling
      snap: true,
      snapTolerance: 5,
      revert: 'invalid',
      handle: '.loop-name',
      opacity: 0.5,
      helper: function () {
        var $clone = $(this).clone();
        $clone.width($(this).data('options').duration * constants.pixelsPerSecond);
        return $clone;
      }
    });
  }

  /**
   * Allow loops from the tracks pane to be dragged
   * to another track.
   * @param  {$object} $elem elements to make draggable
   */
  function applyTracksPaneDraggable ($elem) {
    $elem.draggable({
      appendTo: '.loops',
      snap: true,
      snapTolerance: 5,
      zIndex: 10,
      revert: 'invalid',
      handle: '.loop-name',
      scrollSpeed: 10,
      opacity: 0.5,
      start: function (event, ui) {
        ui.helper.removeClass('collision');
      }
    });
  }

  /**
   * Make the track droppable so draggable loops
   * can be placed.
   * @param  {[type]} $track the track to make droppable
   */
  function applyTracksPaneDroppable ($track) {
    $track.droppable({
      hoverClass: 'track-hover',
      accept: '.loop',
      drop: function (event, ui) {
        var $track = $(this);
        var trackIndex = $track.index('.track');

        // Don't drop if it has collision
        if (hasCollision($track, ui.helper)) {
          // Move it back!
          ui.draggable.draggable('option', 'revert', true);
          ui.helper.addClass('collision');
          return;
        }

        // Set back the invalid revert option
        ui.draggable.draggable('option', 'revert', 'invalid');

        // Moving from track to track
        if (ui.helper.hasClass('track-loop')) {
          var prevTrackIndex = ui.draggable.parent().index('.track');
          // Add loop to the current track
          $track.append(ui.draggable);

          // Fix vertical align
          ui.draggable.css('top', 0);

          // Fire the event
          events.trigger('move', {
            prevTrackIndex: prevTrackIndex,
            trackIndex: trackIndex,
            id: ui.draggable.attr('id')
          });
          return;
        }

        // Moving from loop pane to track
        events.trigger('new', {
          trackIndex: trackIndex,
          loopData: _.extend(ui.draggable.data('options'), {inTrack: true}),
          left: loopHelper.left(ui.helper)
        });
      }
    });
  }

  return {
    applyLoopsPaneDraggable: applyLoopsPaneDraggable,
    applyTracksPaneDraggable: applyTracksPaneDraggable,
    applyTracksPaneDroppable: applyTracksPaneDroppable,
    events: events
  };
});