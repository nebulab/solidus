/**
 * Use this file to store the global modal
 *
 * e.g.
 * Spree.Views.Modals = {
 *   myModal: function($el = null) {
 *     if($el != null) {
 *       this.myGlobalModal = new Spree.Views.Modals.MyModal({el: $el})
 *     }
 *
 *     return this.myGlobalModal;
 *   },
 * }
 *
 */
Spree.Views.Modals = {
  batchPreview: function($el = null) {
    if($el != null) {
      this.modalBatchPreview = new Spree.Views.Modals.Batch.Preview({el: $el})
    }

    return this.modalBatchPreview;
  },

  batchResult: function($el = null) {
    if($el != null) {
      this.modalBatchResult = new Spree.Views.Modals.Batch.Result({el: $el})
    }

    return this.modalBatchResult;
  }
};
