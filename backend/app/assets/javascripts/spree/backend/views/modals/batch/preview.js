Spree.Views.Modals.Batch.Preview = Backbone.View.extend({
  events: {
    'click #btn-process': 'process'
  },

  show: function(options) {
    this.searchForm = options.searchForm;
    this.action = options.action;
    this.$el.modal('show');
  },

  process: function() {
  }
})
