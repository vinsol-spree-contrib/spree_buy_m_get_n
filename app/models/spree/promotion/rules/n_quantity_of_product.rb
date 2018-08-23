module Spree
  class Promotion
    module Rules
      class NQuantityOfProduct < PromotionRule
        has_many :product_promotion_rules, class_name: 'Spree::ProductPromotionRule',
                                           foreign_key: :promotion_rule_id,
                                           dependent: :destroy
        has_many :products, through: :product_promotion_rules, class_name: 'Spree::Product'
        preference :quantity, :integer, default: 1

        validates_numericality_of :preferred_quantity, greater_than_or_equal_to: 1
        MATCH_POLICIES = %w(any all)
        preference :match_policy, :string, default: MATCH_POLICIES.first

        def eligible_products
          products
        end

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          return true if eligible_products.empty?

          if preferred_match_policy == 'all'
            unless includes_all_eligible_products?(order)
              eligibility_errors.add(:base, eligibility_error_message(:missing_product))
            end
          elsif preferred_match_policy == 'any'
            unless order.line_items.any? { |line_item| actionable?(line_item) }
              eligibility_errors.add(:base, eligibility_error_message(:no_applicable_products))
            end
          end

          eligibility_errors.empty?
        end

        def includes_all_eligible_products?(order)
          eligible_products.all? do |product|
            order.line_items.any? do |line_item|
              line_item.variant.product.id == product.id && line_item.quantity >= preferred_quantity
            end
          end
        end

        def actionable?(line_item)
          (product_ids.include?(line_item.variant.product_id)) && line_item.quantity >= preferred_quantity
        end

        def product_ids_string
          product_ids.join(',')
        end

        def product_ids_string=(s)
          self.product_ids = s.to_s.split(',').map(&:strip)
        end
      end
    end
  end
end
