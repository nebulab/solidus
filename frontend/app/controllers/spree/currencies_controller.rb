# frozen_string_literal: true

module Spree
  class CurrenciesController < Spree::StoreController
    include Injector[
      :switch_currency_service
    ]

    def set
      switch_currency(params[:switch_to_currency])

      if current_order && switch_currency_service.call(current_order).failure?
        flash[:error] = t('spree.currency_switch_error')
      end

      redirect_back(fallback_location: root_path)
    end
  end
end
