describe Remotenv::Adapters do
  describe ".self" do
    context "http" do
      let!(:uri) { URI("http://example.com/test.env") }
      subject { Remotenv::Adapters.for(uri) }

      it "correctly returns http adapter" do
        expect(subject.is_a?(Remotenv::Adapters::Http)).to eq(true)
      end

      it "correctly assigns .uri" do
        expect(subject.uri).to eq(uri)
      end
    end

    context "https" do
      let!(:uri) { URI("https://example.com/test.env") }
      subject { Remotenv::Adapters.for(uri) }

      it "correctly returns http adapter" do
        expect(subject.is_a?(Remotenv::Adapters::Http)).to eq(true)
      end

      it "correctly assigns .uri" do
        expect(subject.uri).to eq(uri)
      end
    end

    context "s3" do
      let!(:uri) { URI("s3://example-bucket/test.env") }
      subject { Remotenv::Adapters.for(uri) }

      it "correctly returns http adapter" do
        expect(subject.is_a?(Remotenv::Adapters::S3)).to eq(true)
      end

      it "correctly assigns .uri" do
        expect(subject.uri).to eq(uri)
      end
    end

    context "invalid" do
      let!(:uri) { URI("null://example-bucket/test.env") }
      subject { Remotenv::Adapters.for(uri) }

      it "correctly returns http adapter" do
        expect {
          subject
        }.to raise_error('Could not find adapter for scheme - null')
      end
    end
  end
end
