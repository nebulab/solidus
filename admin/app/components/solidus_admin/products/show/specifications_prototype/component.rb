# frozen_string_literal: true

# PROTOTYPE (throwaway): three UI variants for editing product specifications
# on the product page (upstream #6285). Rendered on /admin/products/:slug?variant=A|B|C.
# Nothing here persists; add/remove/edit actions are client-side stubs.
class SolidusAdmin::Products::Show::SpecificationsPrototype::Component < SolidusAdmin::BaseComponent
  VARIANTS = {
    "A" => "Form: one nested form, saved with the page",
    "B" => "Dialog: single option value per group",
    "B1" => "Dialog: option values as chips + match mode",
    "B2" => "Dialog: one select per option type",
    "B3" => "Dialog: pick the variants directly",
    "C" => "Inline: every row is its own immediate action"
  }.freeze

  def initialize(product:, variant:)
    @product = product
    @variant = VARIANTS.key?(variant) ? variant : "A"
  end

  attr_reader :variant

  def variant_name = VARIANTS.fetch(variant)

  def previous_variant = VARIANTS.keys[(VARIANTS.keys.index(variant) - 1) % VARIANTS.size]

  def next_variant = VARIANTS.keys[(VARIANTS.keys.index(variant) + 1) % VARIANTS.size]

  def variant_url(key) = helpers.url_for(variant: key)

  # Groups as the design models them: "General" (product properties) first,
  # then one group per variant property rule.
  def groups
    @groups ||= [
      {
        title: "General (All values)",
        option_value_id: nil,
        rows: @product.product_properties.includes(:property).map { |pp| {property: pp.property.presentation, value: pp.value} }
      },
      *@product.variant_property_rules.includes(option_values: :option_type, values: :property).order(:id).map do |rule|
        {
          title: rule.option_values.map { |ov| "#{ov.option_type.presentation}: #{ov.presentation}" }.join(rule.apply_to_all ? " + " : ", "),
          option_value_id: rule.option_values.first&.id,
          option_value_ids: rule.option_value_ids,
          apply_to_all: rule.apply_to_all,
          matches: variants.count { |v| rule.applies_to_variant?(v) },
          rows: rule.values.map { |v| {property: v.property.presentation, value: v.value} }
        }
      end
    ]
  end

  def variants = @variants ||= @product.variants.includes(option_values: :option_type).to_a

  def option_types = @option_types ||= @product.option_types.includes(:option_values).to_a

  def dialog_variant? = variant.start_with?("B")

  def scope_label(group)
    return "All variants" if group[:option_value_id].nil?

    "#{group[:matches]} of #{variants.size} variants"
  end

  def option_value_choices
    [["General (All values)", ""]] +
      @product.option_types.includes(:option_values).flat_map do |option_type|
        option_type.option_values.map { |ov| ["#{option_type.presentation}: #{ov.presentation}", ov.id] }
      end
  end

  def property_names = Spree::Property.order(:presentation).pluck(:presentation)
end
