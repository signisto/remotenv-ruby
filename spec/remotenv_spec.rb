require 'remotenv/adapters/s3'

describe Remotenv do
  let!(:url) { "http://example.com/test.env" }
  let!(:uri) { URI(url) }

  before do
    ENV['REMOTENV_URL'] = url
  end

  describe "::VERSION" do
    it 'has a version number' do
      expect(Remotenv::VERSION).not_to be nil
    end
  end

  describe "::uri" do
    it "proxies to utils helper" do
      uri = URI('http://example.com/test.env')
      expect(Remotenv::Utils).to receive(:parsed_uri).and_return(uri)
      expect(Remotenv.uri).to eq(uri)
    end
  end

  describe "::url" do
    it "proxies to utils helper" do
      url = 'http://example.com/test.env'
      expect(Remotenv::Utils).to receive(:parsed_url).and_return(url)
      expect(Remotenv.url).to eq(url)
    end
  end

  describe "::load" do
    it "loads environment via adatper" do
      adapter_mock = double
      expect(Remotenv::Adapters).to receive(:for).with(uri).and_return(adapter_mock)
      expect(adapter_mock).to receive(:load!)
      expect(adapter_mock).to receive(:data).and_return('adapter_key' => 'adapter_value')
      Remotenv.load
      expect(Remotenv.data).to eq('adapter_key' => 'adapter_value')
    end

    it "shouldn't fail when there is no REMOTENV_URL" do
      expect(Remotenv).to receive(:uri).and_return(nil)
      Remotenv.load
      expect(Remotenv.data).to eq({})
    end
  end

  describe "::get" do
    before do
      Remotenv.instance_variable_set(:@data, 'key' => 'value')
    end

    it "gets a value from @data" do
      expect(Remotenv.get('key')).to eq('value')
    end

    it "returns nil if @data does not have it" do
      expect(Remotenv.get('keykey')).to eq(nil)
    end
  end
end
