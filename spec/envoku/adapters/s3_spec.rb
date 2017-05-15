describe Envoku::Adapters::S3 do
  let!(:uri) { URI("http://example.com/test.env") }
  let!(:adapter) { described_class.new(uri) }

  it { expect(adapter.is_a?(Envoku::Adapters::Http)).to eq(true) }

  describe "#config" do
  end

  describe "#remote_uri" do
    it "returns direct_s3_url if not access tokens" do
      direct_url = 'http://s3.amazonaws.com/direct_s3_url'
      expect(adapter).to receive(:direct_s3_url).and_return(direct_url)
      expect(adapter.send(:remote_uri)).to eq(URI(direct_url))
    end

    it "returns signed_s3_url it access tokens are present" do
      adapter.instance_variable_set(:@_config, 'access_key_id' => '123', 'secret_access_key' => 'XXX')
      signed_url = 'http://s3.amazonaws.com/signed_s3_url'
      expect(adapter).to receive(:signed_s3_url).and_return(signed_url)
      expect(adapter.send(:remote_uri)).to eq(URI(signed_url))
    end
  end

  describe "#direct_s3_url" do
  end

  describe "#signed_s3_url" do
  end
end
