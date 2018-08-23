module Spree
  class Promotion
    module Actions
      class CreateSelectedProductAdjustments < PromotionAction
        has_many :promotion_action_line_items, foreign_key: :promotion_action_id
        accepts_nested_attributes_for :promotion_action_line_items

        include Spree::CalculatedAdjustments
        include Spree::AdjustmentSource

        before_validation -> { self.calculator ||= Calculator::FlatPercentNItemTotal.new }

        def perform(options = {})
          order     = options[:order]
          promotion = options[:promotion]
          # byebug
          # p '_'*800
          return unless promotion.eligible?(order)
          create_unique_adjustments(order, order.line_items) do |line_item|
            promotion_action_line_items.any? { |promotion_action_line_item| promotion_action_line_item.variant_id == line_item.variant_id }
          end
        end

        def compute_amount(line_item)
          # byebug
          # p '@'*800
          return 0 unless (promotion.eligible?(line_item.order) && promotion_action_line_item = promotion_action_line_items.select { |promotion_action_line_item| promotion_action_line_item.variant_id == line_item.variant_id }.first)

          amounts = [line_item.amount, compute(line_item, promotion_action_line_item.quantity)]
          order   = line_item.order

          # Prevent negative order totals
          amounts << order.amount - order.adjustments.sum(:amount).abs if order.adjustments.any?

          amounts.min * -1
        end
      end
    end
  end
end
