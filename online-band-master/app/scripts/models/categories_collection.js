define([
  'jquery',
  'underscore',
  'backbone',
  'models/category'
],

function ($, _, Backbone, CategoryModel) {
  'use strict';

  return Backbone.Model.extend({
    /**
     * TODO: Need a RESTful backend!
     * For now, fetch from json files
     */
    url: 'categories.json', // should really just be /categories
    parse: function (categories) {
      var categoryModels = _.map(categories, function (category) {
        return new CategoryModel({
          id: category.key + '.json', // shouldn't need the .json...
          name: category.name,
          count: category.count
        });
      });

      return {
        collection: new Backbone.Collection(categoryModels)
      };
    }
  });
});