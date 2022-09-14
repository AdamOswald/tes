require([
  'jquery',
  'models/categories_collection',
  'views/loops_pane',
  'views/tracks_pane',
  'views/controls_pane',
  'jquery_ui/ui/resizable'
],

function ($, CategoriesCollectionModel, LoopsPaneView, TracksPaneView,ControlsPane ) {
  'use strict';

  // Fetch the list of categories
  var categoriesModel = new CategoriesCollectionModel();
  categoriesModel.fetch().done(function () {
    // Create the loops pane view
    new LoopsPaneView({
      el: '.loops-pane',
      collection: categoriesModel.get('collection')
    }).render();
  });

  // Create the tracks pane view
  var tracksPaneView = new TracksPaneView({
    el: '.loops-main'
  }).render();

  // Let's add a few tracks for the user
  tracksPaneView.addTrack();
  tracksPaneView.addTrack();
  tracksPaneView.addTrack();
  tracksPaneView.addTrack();

  // Create controls pane
  var controlsPaneView = new ControlsPane({
    el: '.controls'
  }).render();

  tracksPaneView.listenTo(controlsPaneView, 'play', tracksPaneView.play);
});