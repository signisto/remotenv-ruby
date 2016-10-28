describe Envoku::Utils do
  describe "::parsed_url" do
    it "returns ENV['ENVOKU_URL']" do
      ENV['ENVOKU_URL'] = "s3://user:password@bucket/filename.env"
      expect(Envoku::Utils.parsed_url).to eq("s3://user:password@bucket/filename.env")
    end

    it "returns nil when blank string" do
      ENV['ENVOKU_URL'] = ""
      expect(Envoku::Utils.parsed_url).to eq(nil)
    end

    it "returns nil when not set" do
      ENV['ENVOKU_URL'] = nil
      expect(Envoku::Utils.parsed_url).to eq(nil)
    end
  end

  describe "::parsed_uri" do
    it "returns nil for an invalid URL" do
      allow(Envoku::Utils).to receive(:parsed_url).and_return("s3://local_host/")
      uri = Envoku::Utils.parsed_uri
      expect(uri).to eq(nil)
    end

    it "parses simple URLs" do
      allow(Envoku::Utils).to receive(:parsed_url).and_return("s3://user:password@bucket/filename.env")
      uri = Envoku::Utils.parsed_uri
      expect(uri.scheme).to eq("s3")
      expect(uri.user).to eq("user")
      expect(uri.password).to eq("password")
      expect(uri.host).to eq("bucket")
      expect(uri.path).to eq("/filename.env")
    end

    it "parses passwords with %2F (/) in them" do
      allow(Envoku::Utils).to receive(:parsed_url).and_return("s3://user:pass%2Fword@bucket/filename.env")
      uri = Envoku::Utils.parsed_uri
      expect(uri.scheme).to eq("s3")
      expect(uri.user).to eq("user")
      expect(uri.password).to eq("pass%2Fword")
      expect(uri.host).to eq("bucket")
      expect(uri.path).to eq("/filename.env")
    end

    it "fails when passwords have / in them" do
      allow(Envoku::Utils).to receive(:parsed_url).and_return("s3://user:pass/word@bucket/filename.env")
      uri = Envoku::Utils.parsed_uri
      expect(uri).to eq(nil)
    end
  end
end
