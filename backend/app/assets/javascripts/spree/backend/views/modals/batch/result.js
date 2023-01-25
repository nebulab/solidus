Spree.Views.Modals.Batch.Result = Backbone.View.extend({
  events: {
    'click #btn-close': 'close'
  },

  show: function() {
    this.$el.modal('show');
  },

  close: function() {
    this.$el.modal('hide');
    document.location.reload();
  }
})
