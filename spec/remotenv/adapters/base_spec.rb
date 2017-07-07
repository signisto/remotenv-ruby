describe Remotenv::Adapters::Base do
  let!(:uri) { URI("http://example.com/test.env") }
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
      }.to raise_error('Remotenv::Adapter::Base should not be used directly')
    end
  end

  describe "#apply_environment" do
    before do
      ENV.delete('key1')
      ENV.delete('KEY_2')
      adapter.instance_variable_set(:@content, "key1=value1\nKEY_2=\"SECOND KEY\"")
    end

    it "sets ENV[key1]" do
      expect {
        adapter.apply_environment
      }.to change { ENV['key1'] }.to 'value1'
    end

    it "sets ENV[KEY_2]" do
      expect {
        adapter.apply_environment
      }.to change { ENV['KEY_2'] }.to 'SECOND KEY'
    end
  end

  describe "#set_refresh_timestamp" do
    it "sets timestamps" do
      time = Time.now.to_s
      expect(Time).to receive(:now).and_return(time)
      expect {
        adapter.set_refresh_timestamp
      }.to change { ENV['REMOTENV_REFRESHED_AT'] }.to time
    end
  end

  describe "#get" do
    it "gets a value from @data" do
      adapter.instance_variable_set(:@data, "key" => "value")
      expect(adapter.get('key')).to eq('value')
    end
  end
end
