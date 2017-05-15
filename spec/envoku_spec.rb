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

  describe "::get" do
    it "proxies to adapter" do
      s3_adapter_mock = double
      expect(Envoku::Adapters::S3).to receive(:new).and_return(s3_adapter_mock)
      expect(s3_adapter_mock).to receive(:load)
      expect(s3_adapter_mock).to receive(:get).with("KEY").and_return("VALUE")
      expect(Envoku.get("KEY")).to eq("VALUE")
    end
  end
end
