require 'rack/utils'

describe Remotenv::Adapters::S3 do
  let!(:uri) { URI("s3://example-bucket/test.env") }
  let!(:adapter) { described_class.new(uri) }

  it { expect(adapter.is_a?(Remotenv::Adapters::Http)).to eq(true) }

  describe "#config" do
    it "returns nil if URI is not valid" do
      expect(Remotenv).to receive(:uri).and_return(nil)
      expect(adapter.send(:config)).to eq({})
    end

    it "returns hash with basic details" do
      expect(Remotenv).to receive(:uri).and_return(uri)
      expect(adapter.send(:config)).to eq({
        'filename' => 'test.env',
        'bucket_name' => 'example-bucket',
      })
    end

    it "returns hash with auth details" do
      uri = URI("s3://abc123:XXX@example-bucket/test.env")
      expect(Remotenv).to receive(:uri).and_return(uri)
      expect(adapter.send(:config)).to eq({
        'filename' => 'test.env',
        'bucket_name' => 'example-bucket',
        'access_key_id' => 'abc123',
        'secret_access_key' => 'XXX',
      })
    end
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
    it "builds a basic http URL" do
      adapter.instance_variable_set(:@_config, 'filename' => 'test.env', 'bucket_name' => 'example-bucket')
      expect(adapter.send(:direct_s3_url)).to eq('https://example-bucket.s3.amazonaws.com/test.env')
    end
  end

  describe "#signed_s3_url" do
    it "constructs a signed URL" do
      config = {
        'filename' => 'test.env',
        'bucket_name' => 'example-bucket',
        'access_key_id' => 'test_ACCESSKEYID',
        'secret_access_key' => 'test_SECRETACCESSKEY',
      }
      adapter.instance_variable_set(:@_config, config)
      signed_s3_url = adapter.send(:signed_s3_url)
      signed_s3_uri = URI(signed_s3_url)
      signed_s3_query_params = Rack::Utils.parse_nested_query(signed_s3_uri.query)
      expect(signed_s3_uri.host).to eq('example-bucket.s3.amazonaws.com')
      expect(signed_s3_uri.path).to eq('/test.env')
      expect(signed_s3_query_params['AWSAccessKeyId']).to eq('test_ACCESSKEYID')
      expect(signed_s3_query_params['Expires'].to_i).to be_between(Time.now.to_i + 60, Time.now.to_i + 300)
      expect(signed_s3_query_params['Signature']).to_not be_nil
    end
  end
end
