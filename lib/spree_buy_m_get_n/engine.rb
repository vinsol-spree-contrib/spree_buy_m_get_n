module SpreeBuyMGetN
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_buy_m_get_n'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Rails.configuration.spree.promotions.rules << Spree::Promotion::Rules::NQuantityOfProduct
      Rails.configuration.spree.promotions.actions << Spree::Promotion::Actions::CreateSelectedProductAdjustments
    end

    config.to_prepare(&method(:activate).to_proc)
  end
end
