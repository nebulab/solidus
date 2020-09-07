Spree.Views.Tables.SelectableTable.Actions = Backbone.View.extend({
  initialize: function(options) {
    this.listenTo(this.model, 'change', this.render);

    this.selectableTable = options.selectableTable;
    this.actions = this.selectableTable.$el.data('actions');
    this.searchForm = $(this.selectableTable.$el.data('searchFormSelector')).clone();

    this.render();
  },

  render: function() {
    var html = HandlebarsTemplates['tables/actions']({
      itemSelected: this.model.get('selectedItems').length > 0 || this.model.get('allSelected'),
      actions: this.actions
    });

    this.$el.html(html);
  },
});
