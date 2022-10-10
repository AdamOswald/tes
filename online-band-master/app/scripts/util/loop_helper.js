define(function () {
  'use strict';

  function getLeft ($loop) {
    // Use css instead of position because the
    // draggable from the loop pane is not appended
    // into a track so it will be incorrect.
    return parseFloat($loop.css('left'));
  }

  function getRight ($loop) {
    var left = getLeft($loop);
    var width = $loop.outerWidth();
    return left + width;
  }

  return {
    left: getLeft,
    right: getRight
  };
});