/**
 * Use this file to retrieve and store the modal that should be global to the
 * site
 *
 * e.g.
 * Spree.ready(function() {
 *   $('#batch-preview').each(function() {
 *     Spree.Views.Modals.batchPreview($(this))
 *   });
 * });
 *
 */
Spree.ready(function() {
  $('#batch-preview').each(function() {
    Spree.Views.Modals.batchPreview($(this))
  })
});
