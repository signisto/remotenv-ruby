class DummyResource
end

describe Envoku::Resource do
  let!(:klass) do
    klass = DummyResource.new
    klass.extend(Envoku::Resource)
    klass
  end

  describe "#enable_feature!" do
    it "calls Envoku::Feature.new(feature).enable_for!(resource)" do
      feature = double('Envoku::Feature')
      expect(feature).to receive(:enable_for!).with(klass)
      expect(Envoku::Feature).to receive(:new).with('FEATURE').and_return(feature)
      klass.enable_feature!('FEATURE')
    end
  end

  describe "#disable_feature!" do
    it "calls Envoku::Feature.new(feature).disable_for!(resource)" do
      feature = double('Envoku::Feature')
      expect(feature).to receive(:disable_for!).with(klass)
      expect(Envoku::Feature).to receive(:new).with('FEATURE').and_return(feature)
      klass.disable_feature!('FEATURE')
    end
  end

  describe "#toggle_feature!" do
    it "calls Envoku::Feature.new(feature).toggle_for!(resource)" do
      feature = double('Envoku::Feature')
      expect(feature).to receive(:toggle_for!).with(klass)
      expect(Envoku::Feature).to receive(:new).with('FEATURE').and_return(feature)
      klass.toggle_feature!('FEATURE')
    end
  end

  describe "#feature_enabled?" do
    it "calls Envoku::Feature.new(feature).enabled_for?(resource)" do
      feature = double('Envoku::Feature')
      expect(feature).to receive(:enabled_for?).with(klass)
      expect(Envoku::Feature).to receive(:new).with('FEATURE').and_return(feature)
      klass.feature_enabled?('FEATURE')
    end
  end

  describe "#features_enabled" do
    it "calls Envoku::features_enabled_for(resource)" do
      expect(Envoku).to receive(:features_enabled_for).with(klass)
      klass.features_enabled
    end
  end
end
