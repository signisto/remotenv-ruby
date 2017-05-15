describe Envoku::Adapters::Base do
  let!(:uri) { "http://example.com/test.env" }
  let!(:adapter) { described_class.new(uri) }

  describe "#initialize" do
  end

  describe "#load!" do
    it "calls methods" do
      expect(adapter).to receive(:before_load)
      expect(adapter).to receive(:load)
      expect(adapter).to receive(:after_load)
      expect(adapter).to receive(:apply_environment)
      expect(adapter).to receive(:set_refresh_timestamp)
      adapter.load!
    end
  end

  describe "#load" do
    it "raises exception when not extended" do
      expect {
        adapter.load
      }.to raise_error('Envoku::Adapter::Base should not be used directly')
    end
  end

  describe "#apply_environment" do
  end

  describe "#set_refresh_timestamp" do
    it "sets timestamps" do
      time = Time.now.to_s
      expect(Time).to receive(:now).and_return(time)
      expect {
        adapter.set_refresh_timestamp
      }.to change { ENV['ENVOKU_REFRESHED_AT'] }.to time
    end
  end

  describe "#get" do
    it "gets a value from @data" do
      adapter.instance_variable_set(:@data, "key" => "value")
      expect(adapter.get('key')).to eq('value')
    end
  end
end
