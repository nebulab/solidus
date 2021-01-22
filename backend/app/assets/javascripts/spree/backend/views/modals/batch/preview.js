Spree.Views.Modals.Batch.Preview = Backbone.View.extend({
  events: {
    'click #btn-process': 'process'
  },

  show: function(options) {
    this.processBatchUrl = options.processBatchUrl;
    this.searchForm = options.searchForm;
    this.action = options.action;
    this.$el.modal('show');
  },

  process: function() {
    var inputAction = document.createElement('input');
    inputAction.name = 'batch_action_type';
    inputAction.value = this.action;
    this.searchForm.append(inputAction);

    this.$el.modal('hide');

    Spree.ajax({
      type: 'POST',
      url: this.processBatchUrl,
      data: this.searchForm.serialize(),
      success: function() {
        Spree.Views.Modals.batchResult().show()
      },
      error: function(msg) {
        if (msg.responseJSON["error"]) {
          show_flash('error', msg.responseJSON["error"]);
        } else {
          show_flash('error', "There was a problem adding this coupon code.");
        }
      }
    });
  }
})
