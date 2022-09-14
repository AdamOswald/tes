define([
  'underscore',
  'backbone',
  'howler',
  'text!../../templates/loop.html',
  '../util/drag_drop_helper',
  '../util/loop_helper',
  '../util/constants',
  'jquery_ui/ui/slider'
],

function (_, Backbone, Howler, Template, dragDropHelper, loopHelper, constants) {
  'use strict';

  return Backbone.View.extend({
    template: _.template(Template),
    className: 'loop',
    events: {
      'click .loop-play:has(.icono-play)': 'play',
      'click .loop-play:has(.icono-pause)': 'pause',
      'click .loop-volume': 'toggleVolume'
    },
    initialize: function (options) {
      this.oldVolume = 0;
      this.name = options.name;
      this.duration = options.duration;
      this.loaded = false;
      this.inTrack = !!options.inTrack;
      this._createHowler(options.src);
      this.$el.attr('id', _.uniqueId('loop-'));
      // Save the data so we can re-create the view
      // on drag/drop
      this.$el.data('options', options);
    },
    /**
     * Create the actual Howler object that is responsible
     * for playing the audio.
     * @param  {array} src the paths of the audio
     */
    _createHowler: function (src) {
      var self = this;

      // Event callbacks
      var onLoad = function () { self._onLoad(); };
      var onPlay = function () { self._syncPlayer(); };
      var onPause = function () { self._stopSyncPlayer(); };

      // Create the howler object
      this.howler = new Howler.Howl({
        src: src,
        loop: !self.inTrack,
        volume: 0.5,
        preload: self.inTrack,
        onload: onLoad,
        onloaderror: this._onLoadError,
        onplay: onPlay,
        onpause: onPause,
        onend: function () {
          if (!self.howler.loop()) {
            self._togglePlayButton();
          }
          self._stopSyncPlayer();
        }
      });
    },
    /**
     * Handler for when the audio is loaded
     */
    _onLoad: function () {
      // Keep track of whether or not this audio is loaded
      this.loaded = true;

      // Set the audio volume to the volume of the ui, in case
      // the user changed the volume before the audio was loaded
      if (this.$volumeSlider) {
        this.howler.volume(this.$volumeSlider.slider('value') / 100);
      }

      // Loop is loaded and it's not in a track, which means that the
      // play button is clicked from the loops pane. Play the song!
      if (!this.inTrack) {
        this.play();
      }
    },
    _onLoadError: function () {
      // TODO: add better handling
      window.alert('Error loading the audio');
    },
    /**
     * Toggle the volume (mute or not). On un-mute, it returns
     * to the original volume before mute
     * @param  {object} event object from click event (optional)
     */
    toggleVolume: function (event) {
      var $target = event? $(event.target) : this.$('.loop-volume');

      // Make sure the volume button is clicked and not the
      // volume dropdown.
      if ($target.is('.loop-volume, .loop-volume-icon')) {
        var tempVolume = this.$volumeSlider.slider('value');
        this.$volumeSlider.slider('value', this.oldVolume);
        this.oldVolume = tempVolume;
      }
    },
    /**
     * Update the volume icon to match the current volume.
     */
    _syncVolume: function () {
      var currentVolume = this.$volumeSlider.slider('value');
      var $volume = this.$('.loop-volume-icon');
      $volume.attr('class', 'loop-volume-icon');
      if (currentVolume > 70) {
        $volume.addClass('icono-volumeHigh');
      } else if (currentVolume > 40) {
        $volume.addClass('icono-volumeMedium');
      } else if (currentVolume > 0) {
        $volume.addClass('icono-volumeLow');
      } else {
        $volume.addClass('icono-volumeMute');
      }
    },
    /**
     * Update the player UI to match the current time of
     * the audio.
     */
    _syncPlayer: function () {
      var self = this;

      // Looks like it's already syncing, nothing to do here!
      if (this.syncInterval) {
        return;
      }

      // Start syncing UI to the audio time
      this.syncInterval = setInterval(function () {
        var currentTime = self.howler.seek();
        var currentPercent = currentTime / self.howler.duration();
        self._updateTime();
        self.$timeSlider.slider('value', currentPercent * 100);
      }, 200);
    },
    /**
     * Stop updating the UI to match the time of the audio.
     */
    _stopSyncPlayer: function () {
      if (this.syncInterval) {
        clearInterval(this.syncInterval);
        this.syncInterval = null;
      }
    },
    /**
     * Pretty print the time
     * @param  {number} time time in seconds ex: 6.42343
     * @return {string} format: minutes:seconds (0:07)
     */
    _formatTime: function (time) {
      // Don't care about miliseconds
      time = Math.floor(time);

      var minutes = Math.floor(time / 60);
      var seconds = time - (minutes * 60);

      if (seconds < 10) {
        seconds = '0' + seconds;
      }

      return minutes + ':' + seconds;
    },
    /**
     * Update the player UI to match the current time
     * of the audio.
     */
    _updateTime: function () {
      // The current time of the audio
      var currentTime = this.howler.seek();

      // The UI that displays the current time
      var $playerTime = this.$('.loop-current-time');

      // Update the player to show the current time
      $playerTime.text(this._formatTime(currentTime));
    },
    /**
     * Get the left position in pixels of the loop from
     * the track
     * @return {number} left css position
     */
    getLeft: function () {
      return loopHelper.left(this.$el);
    },
    /**
     * Get the right position in pixels of the loop from
     * the track
     * @return {number} right css position
     */
    getRight: function () {
      return loopHelper.right(this.$el);
    },
    /**
     * Get the start time in seconds from the beginning
     * of the track
     * @return {number} start time in seconds
     */
    getStart: function () {
      return this.getLeft() / constants.pixelsPerSecond;
    },
    /**
     * Toggle the play/pause button UI
     */
    _togglePlayButton: function () {
      this.$('.loop-play-icon').toggleClass('icono-play icono-pause');
    },
    /**
     * Play the audio if it's not playing.
     * @return {view} the current view
     */
    play: function () {
      if (!this.loaded) {
        // TODO: show loading progress

        // Need to load the audio before we can play it! Unfortuntely
        // the load method doesn't return a promise... Handle the playing
        // in the onload event instead
        this.howler.load();
      } else if (!this.howler.playing()) {
        this.howler.play();
        this._togglePlayButton();
      }
      return this;
    },
    /**
     * Pause the audio if it's playing
     * @return {view} the current view
     */
    pause: function () {
      if (this.howler.playing()) {
        this.howler.pause();
        this._togglePlayButton();
      }
    },
    /**
     * Set the audio to a particular time
     * @param  {number} time seek time in seconds
     * @return {view} the current view
     */
    seek: function (time) {
      this.howler.seek(time);
      this._updateTime();
      return this;
    },
    /**
     * Attach events to make the player functional. Handles
     * creating the volume and time sliders
     */
    _hookUpPlayer: function () {
      var self = this;
      var setVolume = function (event, ui) {
        self.howler.volume(ui.value / 100);
        self._syncVolume();
      };
      var setTime = function (event, ui) {
        // Ignore if it's changed programmatically
        if (self.loaded && event.currentTarget) {
          var time = self.howler.duration() * (ui.value / 100);
          self.seek(time);
        }
      };
      this.$timeSlider = this.$('.loop-time-track').slider({
        orientation: 'horizontal',
        range: 'min',
        slide: setTime,
        change: setTime
      });
      this.$volumeSlider = this.$('.volume-slider').slider({
        orientation: 'vertical',
        range: 'min',
        value: 50,
        slide: setVolume,
        change: setVolume
      });
    },
    /**
     * Hook up draggable to the loop, both from loops pane
     * to track and from track to track.
     */
    _makeDraggable: function () {
      if (this.inTrack) {
        dragDropHelper.applyTracksPaneDraggable(this.$el);
      } else {
        dragDropHelper.applyLoopsPaneDraggable(this.$el);
      }
    },
    render: function () {
      this.$el.html(this.template({
        name: this.name,
        duration: this._formatTime(this.duration)
      }));
      this._hookUpPlayer();
      this._makeDraggable();
      return this;
    }
  });
});