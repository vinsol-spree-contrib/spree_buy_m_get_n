require_dependency 'spree/calculator'

module Spree
  class Calculator::FlatPercentNItemTotal < Calculator
    preference :flat_percent, :decimal, default: 0

    def self.description
      Spree.t(:flat_percent_n_item_total)
    end

    def compute(object, preferred_max_applicable_quantity)
      return 0 if object.quantity == 0
      max_applicable_quantity = [object.quantity, preferred_max_applicable_quantity].min
      computed_amount = ((object.amount * max_applicable_quantity/object.quantity.to_f) * preferred_flat_percent / 100).round(2)

      # We don't want to cause the promotion adjustments to push the order into a negative total.
      if computed_amount > object.amount
        object.amount
      else
        computed_amount
      end
    end
  end
end
