require 'envoku/adapters/s3'
require 'dotenv'
require 'fileutils'

describe Envoku::Adapters::S3 do

  describe "#initialize" do
    it "sets options variable" do
      options = { test: 1 }
      instance = Envoku::Adapters::S3.new options
      expect(instance.instance_variable_get :'@options').to eq options
    end
    it "sets local_file_name variable" do
      instance = Envoku::Adapters::S3.new
      expect(instance.instance_variable_get :'@local_file_name').not_to be nil
    end
  end

  describe "#load" do
    context "when credentials are missing" do
      it "loads dotenv then skips" do
        instance = Envoku::Adapters::S3.new
        expect(Dotenv).to receive(:load).with(no_args)
        expect(instance).to receive(:credentials).and_return nil
        expect(FileUtils).not_to receive(:rm)
        expect(instance).not_to receive(:clone_s3_file)
        instance.load
        expect(ENV['ENVOKU_REFRESHED_AT']).to be nil
      end
    end
    context "when file clones correctly" do
      it "loads the environment" do
        local_file_name = "/tmp/envoku-test.env"
        instance = Envoku::Adapters::S3.new
        instance.instance_variable_set :'@local_file_name', local_file_name
        expect(Dotenv).to receive(:load).with(no_args)
        expect(instance).to receive(:credentials).and_return(bucket: 'test')
        expect(instance).to receive(:clone_s3_file).and_return true
        expect(Dotenv).to receive(:load).with(local_file_name)
        expect(FileUtils).to receive(:rm).with(local_file_name)
        instance.load
        expect(ENV['ENVOKU_REFRESHED_AT']).not_to be nil
      end
    end
    context "when s3 clone fails" do
      it "loads the environment" do
        local_file_name = "/tmp/envoku-test.env"
        instance = Envoku::Adapters::S3.new
        instance.instance_variable_set :'@local_file_name', local_file_name
        expect(Dotenv).to receive(:load).with(no_args)
        expect(instance).to receive(:credentials).and_return(bucket: 'test')
        expect(instance).to receive(:clone_s3_file).and_return false
        expect(Dotenv).not_to receive(:load)
        expect(FileUtils).not_to receive(:rm)
        instance.load
        expect(ENV['ENVOKU_REFRESHED_AT']).to be nil
      end
    end
  end

  describe "#credentials" do
    def set_default_aws_keys
      ENV['ENVOKU_BUCKET'] = "ENVOKU_BUCKET"
      ENV['AWS_ACCESS_KEY_ID'] = "AWS_ACCESS_KEY_ID"
      ENV['AWS_SECRET_ACCESS_KEY'] = "AWS_SECRET_ACCESS_KEY"
    end
    def set_envoku_aws_keys
      ENV['ENVOKU_BUCKET'] = "ENVOKU_BUCKET"
      ENV['ENVOKU_ACCESS_KEY_ID'] = "ENVOKU_ACCESS_KEY_ID"
      ENV['ENVOKU_SECRET_ACCESS_KEY'] = "ENVOKU_SECRET_ACCESS_KEY"
    end
    let(:instance) { Envoku::Adapters::S3.new }
    context "when no keys are set" do
      it "raises an exception" do
        credentials = instance.send(:credentials)
        expect(credentials).to be nil
      end
    end
    context "when default AWS keys are set" do
      it "uses default keys" do
        set_default_aws_keys
        credentials = instance.send(:credentials)
        expect(credentials.access_key_id).to eq "AWS_ACCESS_KEY_ID"
        expect(credentials.secret_access_key).to eq "AWS_SECRET_ACCESS_KEY"
      end
    end
    context "when default AWS keys are set" do
      it "overrides default keys" do
        set_default_aws_keys
        set_envoku_aws_keys
        credentials = instance.send(:credentials)
        expect(credentials.access_key_id).to eq "ENVOKU_ACCESS_KEY_ID"
        expect(credentials.secret_access_key).to eq "ENVOKU_SECRET_ACCESS_KEY"
      end
    end
    context "when options are passed" do
      it "overrides default and envoku keys" do
        set_default_aws_keys
        set_envoku_aws_keys
        instance = Envoku::Adapters::S3.new(
          bucket: 'test-bucket',
          access_key_id: 'test-access-key-id',
          secret_access_key: 'test-secret-access-key',
        )
        credentials = instance.send(:credentials)
        expect(credentials.bucket_name).to eq 'test-bucket'
        expect(credentials.access_key_id).to eq "test-access-key-id"
        expect(credentials.secret_access_key).to eq "test-secret-access-key"
      end
    end
  end

end
