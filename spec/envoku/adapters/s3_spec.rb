describe Envoku::Adapters::S3 do
  let!(:uri) { "http://example.com/test.env" }
  let!(:adapter) { described_class.new(uri) }

  it { expect(adapter.is_a?(Envoku::Adapters::Http)).to eq(true) }

  describe "#config" do
  end

  describe "#remote_url" do
  end
end
