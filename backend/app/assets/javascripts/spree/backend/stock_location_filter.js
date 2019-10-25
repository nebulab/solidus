Spree.ready(function() {
  var $shippingMethodAvailableToAll = $('#shipping_method_available_to_all');

  function showStockLocationCheckboxes() {
    $('#shipping_method_stock_locations_field').toggleClass('hidden', $shippingMethodAvailableToAll.is(':checked'));
  }

  $shippingMethodAvailableToAll.change(function(event){
    showStockLocationCheckboxes();
  });

  showStockLocationCheckboxes();
});
