Spree.Views.Tables.SelectableTable.Actions = Backbone.View.extend({
  events: {
    'click a.batch-action': 'previewBatchAction'
  },

  initialize: function(options) {
    this.listenTo(this.model, 'change', this.render);

    this.selectableTable = options.selectableTable;
    this.actions = this.selectableTable.$el.data('actions');
    this.searchForm = $(this.selectableTable.$el.data('searchFormSelector')).clone();
    this.previewBatchUrl = this.selectableTable.$el.data('previewBatchUrl');
    this.processBatchUrl = this.selectableTable.$el.data('processBatchUrl');

    this.render();
  },

  render: function() {
    var html = HandlebarsTemplates['tables/actions']({
      itemSelected: this.model.get('selectedItems').length > 0 || this.model.get('allSelected'),
      actions: this.actions
    });

    this.$el.html(html);
  },

  previewBatchAction: function(e) {
    var self = this;

    var action = $(e.currentTarget).data('action');
    var inputAction = document.createElement('input');
    inputAction.name = 'batch_action_type';
    inputAction.value = action;

    if(this.selectableTable.$el.find('.selectAll:checked').length == 0) {
      this.selectableTable.$el.find('.selectable:checked').each(function(_i, item){
        self.searchForm.append($(item).clone());
      })
    }

    this.searchForm.append(inputAction);

    options = {
      processBatchUrl: this.processBatchUrl,
      searchForm: this.searchForm,
      action: action
    }

    Spree.ajax({
      type: 'POST',
      url: this.previewBatchUrl,
      data: this.searchForm.serialize(),
      success: function() {
        Spree.Views.Modals.batchPreview().show(options);
      },
      error: function(msg) {
        if (msg.responseJSON["error"]) {
          show_flash('error', msg.responseJSON["error"]);
        } else {
          show_flash('error', "There was a problem adding this coupon code.");
        }
      }
    });

    this.searchForm = $(this.selectableTable.$el.data('searchFormSelector')).clone();
  }
});
