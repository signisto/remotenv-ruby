require 'net/http'

describe Remotenv::Adapters::Http do
  let!(:uri) { URI("http://example.com/test.env") }
  let!(:adapter) { described_class.new(uri) }

  it { expect(adapter.is_a?(Remotenv::Adapters::Base)).to eq(true) }

  describe "#remote_uri" do
  end

  describe "#load" do
    it "calls .download_file" do
      expect(adapter).to receive(:download_file)
      adapter.load
    end
  end

  describe "#download_file" do
    it "assigns .http_get_content to @content" do
      expect(adapter).to receive(:http_get_content).and_return('KEY=VALUE')
      expect {
        adapter.send(:download_file)
      }.to change { adapter.instance_variable_get(:@content) }.to('KEY=VALUE')
    end

    it "does not assign @content if .http_get_content returns nil" do
      expect(adapter).to receive(:http_get_content).and_return(nil)
      expect {
        adapter.send(:download_file)
      }.not_to change { adapter.instance_variable_get(:@content) }
    end
  end

  describe "#http_get_content" do
    it "returns body from external URL" do
      response = double
      expect(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return true
      expect(response).to receive(:body).and_return('KEY=VALUE')
      expect(Net::HTTP).to receive(:get_response).and_return(response)
      content = adapter.send(:http_get_content)
      expect(content).to eq('KEY=VALUE')
    end

    it "returns nil if external request is not a 200 OK" do
      response = double
      expect(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return false
      expect(Net::HTTP).to receive(:get_response).and_return(response)
      content = adapter.send(:http_get_content)
      expect(content).to eq(nil)
    end

    it "returns nil if external request raises an exception" do
      expect(Net::HTTP).to receive(:get_response).and_raise('HTTP FAILURE')
      content = adapter.send(:http_get_content)
      expect(content).to eq(nil)
    end
  end
end
