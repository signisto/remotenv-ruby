require 'envoku/adapters/s3'

describe Envoku do
  let!(:url) { "http://example.com/test.env" }
  let!(:uri) { URI(url) }

  before do
    ENV['ENVOKU_URL'] = url
  end

  describe "::VERSION" do
    it 'has a version number' do
      expect(Envoku::VERSION).not_to be nil
    end
  end

  describe "::uri" do
    it "proxies to utils helper" do
      uri = URI('http://example.com/test.env')
      expect(Envoku::Utils).to receive(:parsed_uri).and_return(uri)
      expect(Envoku.uri).to eq(uri)
    end
  end

  describe "::url" do
    it "proxies to utils helper" do
      url = 'http://example.com/test.env'
      expect(Envoku::Utils).to receive(:parsed_url).and_return(url)
      expect(Envoku.url).to eq(url)
    end
  end

  describe "::load" do
    it "loads environment via adatper" do
      adapter_mock = double
      expect(Envoku::Adapters).to receive(:for).with(uri).and_return(adapter_mock)
      expect(adapter_mock).to receive(:load!)
      expect(adapter_mock).to receive(:data).and_return('adapter_key' => 'adapter_value')
      Envoku.load
      expect(Envoku.data).to eq('adapter_key' => 'adapter_value')
    end
  end

  describe "::get" do
    before do
      Envoku.instance_variable_set(:@data, 'key' => 'value')
    end

    it "gets a value from @data" do
      expect(Envoku.get('key')).to eq('value')
    end

    it "returns nil if @data does not have it" do
      expect(Envoku.get('keykey')).to eq(nil)
    end
  end
end
