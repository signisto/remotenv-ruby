require 'envoku/adapters/s3'

describe Envoku do
  let(:klass) { DummyResource.new(id: 1) }

  describe "::VERSION" do
    it 'has a version number' do
      expect(Envoku::VERSION).not_to be nil
    end
  end

  describe "::load" do
    it "loads environment via S3 adatper" do
      options = {
        test: 1,
      }
      s3_adapter_mock = double
      expect(Envoku::Adapters::S3).to receive(:new).with(options).and_return s3_adapter_mock
      expect(s3_adapter_mock).to receive(:load)
      Envoku.load options
    end
  end

  describe "::redis" do
    it "calls Redis.new with ENVOKU_REDIS_URL" do
      ENV['ENVOKU_REDIS_URL'] = "redis://localhost:1234/0"
      ENV['REDIS_URL'] = "redis://localhost:5678/1"
      expect(Redis).to receive(:new).with(url: "redis://localhost:1234/0")
      Envoku.redis
    end
    it "calls Redis.new with REDIS_URL" do
      ENV['REDIS_URL'] = "redis://localhost:5678/1"
      expect(Redis).to receive(:new).with(url: "redis://localhost:5678/1")
      Envoku.redis
    end
    it "calls Redis.new with no URL" do
      expect(Redis).to receive(:new).with(url: nil)
      Envoku.redis
    end
  end

  describe "::feature_enabled_for?" do
    it "calls Envoku::Feature.new(feature).enabled_for?(resource)" do
      feature = double('Envoku::Feature')
      expect(feature).to receive(:enabled_for?).with(klass)
      expect(Envoku::Feature).to receive(:new).with('FEATURE').and_return(feature)
      Envoku.feature_enabled_for?('FEATURE', klass)
    end
  end

  describe "::features_enabled_for" do
    it "returns correct resources" do
      feature1 = Envoku::Feature.new('DUMMY1')
      feature2 = Envoku::Feature.new('DUMMY2')
      resource1 = DummyResource.new(id: 1)
      resource2 = DummyResource.new(id: 2)
      puts "id = #{resource2.id}"
      feature1.enable_for!(resource1)
      feature2.enable_for!(resource1)
      feature2.enable_for!(resource2)
      expect(Envoku.features_enabled_for(resource1).sort).to eq(['DUMMY1', 'DUMMY2'])
      expect(Envoku.features_enabled_for(resource2).sort).to eq(['DUMMY2'])
    end
  end
end
