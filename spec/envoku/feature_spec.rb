describe Envoku::Feature do
  let(:feature) { Envoku::Feature.new('DUMMY1') }
  let(:resource) { DummyResource.new(id: 1) }

  describe "::all" do
    it "initializes Envoku::Feature for each ENV variable" do
      ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'"
      ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY2"] = "description: 'something'"
      expect(Envoku::Feature).to receive(:new).with('DUMMY1')
      expect(Envoku::Feature).to receive(:new).with('DUMMY2')
      Envoku::Feature.all
    end
  end

  describe "#initialize" do
    context "key does not exist" do
      it "creates shell feature" do
        feature = Envoku::Feature.new('DUMMY1')
        expect(feature.name).to eq('DUMMY1')
        expect(feature.description).to eq(nil)
        expect(feature.enabled?).to eq(false)
      end
    end
    context "invalid YAML syntax" do
      it "does not raise exception" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something', enabled: true"
        expect(feature.name).to eq('DUMMY1')
        expect(feature.description).to eq(nil)
        expect(feature.enabled?).to eq(false)
      end
    end
    context "description exists" do
      it "applies description" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'"
        expect(feature.name).to eq('DUMMY1')
        expect(feature.description).to eq('something')
        expect(feature.enabled?).to eq(false)
      end
    end
    context "globally enabled" do
      it "sets enabled to true" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\nenabled: true"
        expect(feature.name).to eq('DUMMY1')
        expect(feature.description).to eq('something')
        expect(feature.enabled?).to eq(true)
      end
    end
  end

  describe "#attributes" do
    context "no custom data password" do
      it "is en empty hash" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\nenabled: true"
        expect(feature.name).to eq('DUMMY1')
        expect(feature.description).to eq('something')
        expect(feature.attributes).to eq({})
        expect(feature.enabled?).to eq(true)
      end
    end
    context "custom attributes" do
      it "contains just the custom attributes" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\nenabled: true\npermitted_resources: 'Organization'"
        expect(feature.name).to eq('DUMMY1')
        expect(feature.description).to eq('something')
        expect(feature.attributes).to eq({"permitted_resources" => "Organization"})
        expect(feature.enabled?).to eq(true)
      end
    end
  end

  describe "#enabled?" do
    it "proxies @enabled" do
      feature.instance_variable_set(:'@enabled', true)
      expect(feature.enabled?).to eq(true)
      feature.instance_variable_set(:'@enabled', false)
      expect(feature.enabled?).to eq(false)
    end
  end

  describe "#enabled_for?" do
    context "globally enabled" do
      it "returns true" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\nenabled: true"
        expect(feature.enabled_for?(resource)).to eq(true)
      end
    end
    context "not globally enabled and redis values set" do
      it "returns true" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\nenabled: false"
        Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}#{feature.name}:#{resource.class.name}", resource.id.to_s)
        Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}#{resource.class.name}:#{resource.id}", feature.name)
        expect(feature.enabled_for?(resource)).to eq(true)
      end
    end
  end

  describe "#enable_for!" do
    it "sets redis values" do
      ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\nenabled: false"
      feature.enable_for!(resource)
      expect(Envoku.redis.smembers("#{Envoku::Feature::REDIS_NAMESPACE}#{feature.name}:#{resource.class.name}")).to eq([resource.id.to_s])
      expect(Envoku.redis.smembers("#{Envoku::Feature::REDIS_NAMESPACE}#{resource.class.name}:#{resource.id}")).to eq([feature.name])
    end
  end

  describe "#disable_for!" do
    it "removes redis values" do
      ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\nenabled: false"
      Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}#{feature.name}:#{resource.class.name}", resource.id.to_s)
      Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}#{resource.class.name}:#{resource.id}", feature.name)
      feature.disable_for!(resource)
      expect(Envoku.redis.smembers("#{Envoku::Feature::REDIS_NAMESPACE}#{feature.name}:#{resource.class.name}")).to eq([])
      expect(Envoku.redis.smembers("#{Envoku::Feature::REDIS_NAMESPACE}#{resource.class.name}:#{resource.id}")).to eq([])
    end
  end

  describe "#toggle_for!" do
    it "toggles on" do
      expect(feature).to receive(:enabled_for?).with(resource).and_return(false)
      expect(feature).to receive(:enable_for!).with(resource)
      feature.toggle_for!(resource)
    end
    it "toggles off" do
      expect(feature).to receive(:enabled_for?).with(resource).and_return(true)
      expect(feature).to receive(:disable_for!).with(resource)
      feature.toggle_for!(resource)
    end
  end

  describe "permitted_for?" do
    context "class name as string" do
      it "returns true when permitted globally" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'"
        expect(feature.permitted_for?('DummyResource')).to eq(true)
      end
      it "returns true when permitted for this resource" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\npermitted_resources: 'DummyResource'"
        expect(feature.permitted_for?('DummyResource')).to eq(true)
      end
      it "returns true when permitted for this resource" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\npermitted_resources: 'NonExistentResource'"
        expect(feature.permitted_for?('DummyResource')).to eq(false)
      end
    end
    context "class passed directly" do
      it "returns true when permitted globally" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'"
        expect(feature.permitted_for?(resource)).to eq(true)
      end
      it "returns true when permitted for this resource" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\npermitted_resources: 'DummyResource'"
        expect(feature.permitted_for?(resource)).to eq(true)
      end
      it "returns true when permitted for this resource" do
        ENV["#{Envoku::Feature::ENV_NAMESPACE}DUMMY1"] = "description: 'something'\npermitted_resources: 'NonExistentResource'"
        expect(feature.permitted_for?(resource)).to eq(false)
      end
    end
  end

  describe "#resources" do
    it "returns grouped resources" do
      Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}#{feature.name}:Org", "1")
      Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}Org:1", feature.name)
      Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}#{feature.name}:User", "1")
      Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}User:1", feature.name)
      Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}#{feature.name}:User", "2")
      Envoku.redis.sadd("#{Envoku::Feature::REDIS_NAMESPACE}User:2", feature.name)
      expect(feature.resources.sort).to eq(["Org:1", "User:1", "User:2"])
    end
  end
end
