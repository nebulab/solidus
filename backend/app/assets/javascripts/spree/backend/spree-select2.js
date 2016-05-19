//= require select2
$.fn.spreeSelect2 = function () {
  'use strict';

  this.select2({
    allowClear: true,
    dropdownAutoWidth: true,
    minimumResultsForSearch: 8
  })
}

jQuery(function($) {
  // Make select beautiful
  $('select.select2').spreeSelect2();

  function format_taxons(taxon) {
    new_taxon = taxon.text.replace('->', '<i class="fa fa-arrow-right">')
    return new_taxon;
  }
})
