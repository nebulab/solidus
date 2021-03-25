Spree.Views.Tables.SelectableTable.Summary = Backbone.View.extend({
  events: {
    'click input[name="select-all"]': 'onSelectedAll'
  },

  onSelectedAll: function(event) {
    this.model.set('allSelected', event.currentTarget.checked);
    if(event.currentTarget.checked == false) {
      this.model.set('selectedItems', []);
    }
  },

  initialize: function(options) {
    this.listenTo(this.model, 'change', this.render)

    this.colspan = options.columns - 1;
    this.actionableColspan = 0

    this.selectableTable = options.selectableTable;
    this.actionable = this.selectableTable.$el.hasClass('actionable')

    if(this.actionable) {
      this.colspan = options.columns - 3
      this.actionableColspan = 3
    }

    this.render();
  },

  render: function() {
    var selectedItemLength = this.model.get('selectedItems').length;
    var all_items_selected = this.model.get('allSelected');

    var html = HandlebarsTemplates['tables/selectable_label']({
      actionable: this.actionable,
      actionableColspan: this.actionableColspan,
      colspan: this.colspan,
      item_selected_label: this.selectedItemLabel(all_items_selected, selectedItemLength),
      all_items_selected: all_items_selected
    });

    this.$el.html(html);

    if(this.actionable) {
      new Spree.Views.Tables.SelectableTable.Actions({
        el: this.$el.find('th.actions'),
        model: this.model,
        selectableTable: this.selectableTable,
      });
    }
  },

  selectedItemLabel: function(all_selected, selected_item_length) {
    if(all_selected) {
      return Spree.t('items_selected.all');
    } else if(selected_item_length == 0) {
      return Spree.t('items_selected.none');
    } else if(selected_item_length == 1) {
      return Spree.t('items_selected.one');
    } else {
      return selected_item_length + " " + Spree.t('items_selected.custom');
    }
  }
});
