module Envoku
  module Resource
    def disable_feature!(feature)
      ::Envoku::Feature.new(feature).disable_for!(self)
    end

    def enable_feature!(feature)
      ::Envoku::Feature.new(feature).enable_for!(self)
    end

    def feature_enabled?(feature)
      ::Envoku::Feature.new(feature).enabled_for?(self)
    end

    def features_enabled
      ::Envoku.features_enabled_for(self)
    end

    def toggle_feature!(feature)
      ::Envoku::Feature.new(feature).toggle_for!(self)
    end
  end
end
