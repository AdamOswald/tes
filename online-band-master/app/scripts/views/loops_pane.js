define([
  'backbone',
  'jquery',
  'underscore',
  './loop_player',
  'text!../../templates/loops_pane.html',
  'jquery_ui/ui/draggable'
],

function (Backbone, $, _, LoopPlayerView, Template) {
  'use strict';

  return Backbone.View.extend({
    template: _.template(Template),
    events: {
      'click .hover-button': 'showCategoryLoops'
    },
    categoryViews: {},
    initialize: function (options) {
      this.collection = options.collection;
    },
    createCategory: function (categoryModel, $categoryContainer) {
      var self = this;
      categoryModel.fetch().done(function (loops) {
        _.each(loops, function (loop) {
          var newLoop = new LoopPlayerView(loop).render();
          self.categoryViews[loop.category] = self.categoryViews[loop.category] || [];
          self.categoryViews[loop.category].push(newLoop);
          $categoryContainer.append(newLoop.$el);
        });
      });
    },
    showCategoryLoops: function (event) {
      var $categoryButton = $(event.currentTarget),
          category = $categoryButton.data('category'),
          $categoryContainer = this.$('.category-loops[data-category="' + category +'"]'),
          categoryModel = this.collection.get(category);

      // Set as active category
      $categoryButton.toggleClass('active').siblings().removeClass('active');

      if (!$categoryButton.hasClass('active')) {
        // We have no active category, don't show anything!
        $categoryContainer.hide();
        return;
      }

      // Category hasn't been created yet
      if (!categoryModel.get('loops')) {
        this.createCategory(categoryModel, $categoryContainer);
      }

      $categoryContainer.fadeIn('slow').siblings().hide();
    },
    render: function () {
      this.$el.html(this.template({
        categories: this.collection.toJSON()
      }));
      return this;
    }
  });
});