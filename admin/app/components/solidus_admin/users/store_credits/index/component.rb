# frozen_string_literal: true

class SolidusAdmin::Users::StoreCredits::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(user:, store_credits:)
    @user = user
    @store_credits = store_credits
  end

  def model_class
    Spree::StoreCredit
  end

  def rows
    @store_credits
  end

  def show_path(store_credit)
    solidus_admin.user_store_credit_path(@user, store_credit)
  end

  def new_store_credit_path
    solidus_admin.new_user_store_credit_path(user_id: @user.id)
  end

  def columns
    [
      {
        header: :credited,
        col: { class: "w-[12%]" },
        data: ->(store_credit) do
          link_to store_credit.display_amount.to_html, show_path(store_credit), class: "body-link text-sm"
        end
      },
      {
        header: :authorized,
        col: { class: "w-[13%]" },
        data: ->(store_credit) do
          link_to store_credit.display_amount_authorized.to_html, show_path(store_credit), class: "body-link text-sm"
        end
      },
      {
        header: :used,
        col: { class: "w-[9%]" },
        data: ->(store_credit) do
          link_to store_credit.display_amount_used.to_html, show_path(store_credit), class: "body-link text-sm"
        end
      },
      {
        header: :type,
        col: { class: "w-[13%]" },
        data: ->(store_credit) do
          component('ui/badge').new(name: store_credit.credit_type.name, color: :blue)
        end
      },
      {
        header: :created_by,
        col: { class: "w-[22%]" },
        data: ->(store_credit) do
          content_tag :div, store_credit.created_by_email, class: "text-sm"
        end
      },
      {
        header: :issued_on,
        col: { class: "w-[16%]" },
        data: ->(store_credit) do
          content_tag :span, I18n.l(store_credit.created_at.to_date), class: "text-sm"
        end
      },
      {
        header: :invalidated,
        col: { class: "w-[15%]" },
        data: ->(store_credit) do
          if store_credit.invalidated?
            component('ui/badge').new(name: :yes, color: :red, size: :m)
          else
            component('ui/badge').new(name: :no, color: :green, size: :m)
          end
        end
      }
    ]
  end
end
