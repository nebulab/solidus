# frozen_string_literal: true

module Spree
  class CurrenciesController < Spree::StoreController
    def set
      switch_currency(params[:switch_to_currency])

      if current_order && switch_currency_service.call(current_order).failure?
        flash[:error] = t('spree.currency_switch_error')
      end

      redirect_back(fallback_location: root_path)
    end

    private

    def switch_currency_service
      Spree::Config.switch_currency_service_class.new
    end
  end
end
