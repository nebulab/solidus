Spree.Views.Modals.Batch.Preview = Backbone.View.extend({
  show: function(options) {
    this.searchForm = options.searchForm;
    this.action = options.action;
    this.$el.modal('show');
  },
})
