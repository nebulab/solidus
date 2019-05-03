module Spree
  class CountryListPresenter < Spree::Presenter::Base
    def initialize(presentee)
      presentee = prepare_countries(presentee)

      super
    end

    protected

    def prepare_countries(countries)
      countries.map { |country| Spree::CountryPresenter.new(country) }.sort_by { |c| c.name.parameterize }
    end
  end
end
