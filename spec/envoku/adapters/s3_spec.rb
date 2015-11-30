require 'envoku/adapters/s3'
require 'dotenv'
require 'fileutils'

describe Envoku::Adapters::S3 do

  describe "#initialize" do
    it "sets options variable" do
      options = { test: 1, bucket_name: 'test' }
      instance = Envoku::Adapters::S3.new options
      expect(instance.instance_variable_get :'@options').to eq OpenStruct.new(
        test: 1,
        filename: nil,
        bucket_name: 'test',
        access_key_id: nil,
        secret_access_key: nil,
      )
    end
    it "sets local_file_name variable" do
      instance = Envoku::Adapters::S3.new
      expect(instance.instance_variable_get :'@local_file_name').not_to be nil
    end
  end

  describe "#load" do
    context "when options are missing" do
      it "loads dotenv then skips" do
        expect_any_instance_of(Envoku::Adapters::S3).to receive(:apply_environment_options)
        instance = Envoku::Adapters::S3.new
        expect(Dotenv).to receive(:load).with(no_args)
        expect(instance).to receive(:options).and_return OpenStruct.new
        expect(FileUtils).not_to receive(:rm)
        expect(instance).not_to receive(:clone_s3_file)
        instance.load
        expect(ENV['ENVOKU_REFRESHED_AT']).to be nil
      end
    end
    context "when file clones correctly" do
      it "loads the environment" do
        expect_any_instance_of(Envoku::Adapters::S3).to receive(:apply_environment_options)
        local_file_name = "/tmp/envoku-test.env"
        instance = Envoku::Adapters::S3.new
        instance.instance_variable_set :'@local_file_name', local_file_name
        expect(Dotenv).to receive(:load).with(no_args)
        expect(instance).to receive(:options).at_least(:once).and_return(OpenStruct.new bucket_name: 'test', filename: 'test.env', access_key_id: 'XXX', secret_access_key: 'XXXXX')
        expect(instance).to receive(:clone_s3_file).and_return true
        expect(Dotenv).to receive(:load).with(local_file_name)
        expect(FileUtils).to receive(:rm).with(local_file_name)
        instance.load
        expect(ENV['ENVOKU_REFRESHED_AT']).not_to be nil
      end
    end
    context "when s3 clone fails" do
      it "loads the environment" do
        expect_any_instance_of(Envoku::Adapters::S3).to receive(:apply_environment_options)
        local_file_name = "/tmp/envoku-test.env"
        instance = Envoku::Adapters::S3.new
        instance.instance_variable_set :'@local_file_name', local_file_name
        expect(Dotenv).to receive(:load).with(no_args)
        expect(instance).to receive(:options).at_least(:once).and_return(OpenStruct.new bucket_name: 'test', filename: 'test.env', access_key_id: 'XXX', secret_access_key: 'XXXXX')
        expect(instance).to receive(:clone_s3_file).and_return false
        expect(Dotenv).not_to receive(:load)
        expect(FileUtils).not_to receive(:rm)
        instance.load
        expect(ENV['ENVOKU_REFRESHED_AT']).to be nil
      end
    end
  end

  describe "#options" do
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
    def set_invalid_envoku_url
      ENV['ENVOKU_URL'] = "s3.amazonaws.com/bucket-name"
    end
    def set_valid_envoku_url
      ENV['ENVOKU_URL'] = "s3://URL_ACCESS_KEY_ID:URL_SECRET_ACCES_KEY@url-bucket-name/url-filename.env"
    end
    let(:instance) { Envoku::Adapters::S3.new }

    context "when ENVOKU_URL is not set" do
      context "when no keys are set" do
        it "returns no options" do
          instance.send(:apply_environment_options)
          expect(instance.options).to eq OpenStruct.new(filename: nil, bucket_name: nil, access_key_id: nil, secret_access_key: nil)
        end
      end
      context "when default AWS keys are set" do
        it "uses default keys" do
          set_default_aws_keys
          instance.send(:apply_environment_options)
          expect(instance.options.access_key_id).to eq "AWS_ACCESS_KEY_ID"
          expect(instance.options.secret_access_key).to eq "AWS_SECRET_ACCESS_KEY"
        end
      end
      context "when Envoku AWS keys are set" do
        it "overrides default keys" do
          set_default_aws_keys
          set_envoku_aws_keys
          instance.send(:apply_environment_options)
          expect(instance.options.access_key_id).to eq "ENVOKU_ACCESS_KEY_ID"
          expect(instance.options.secret_access_key).to eq "ENVOKU_SECRET_ACCESS_KEY"
        end
      end
      context "when options are passed" do
        it "overrides default and envoku keys" do
          set_default_aws_keys
          set_envoku_aws_keys
          instance = Envoku::Adapters::S3.new(
            bucket_name: 'test-bucket',
            access_key_id: 'test-access-key-id',
            secret_access_key: 'test-secret-access-key',
          )
          instance.send(:apply_environment_options)
          expect(instance.options.bucket_name).to eq 'test-bucket'
          expect(instance.options.access_key_id).to eq "test-access-key-id"
          expect(instance.options.secret_access_key).to eq "test-secret-access-key"
        end
      end
    end

    context "when ENVOKU_URL is set" do
      context "when URL is valid" do
        it "returns no options" do
          set_default_aws_keys
          set_envoku_aws_keys
          set_invalid_envoku_url
          instance.send(:apply_environment_options)
          expect(instance.options).to eq OpenStruct.new(bucket_name: nil, filename: nil, access_key_id: nil, secret_access_key: nil)
        end
      end
      context "when URL is valid" do
        it "overrides all other keys" do
          set_default_aws_keys
          set_envoku_aws_keys
          set_valid_envoku_url
          instance.send(:apply_environment_options)
          expect(instance.options.filename).to eq 'url-filename.env'
          expect(instance.options.bucket_name).to eq 'url-bucket-name'
          expect(instance.options.access_key_id).to eq "URL_ACCESS_KEY_ID"
          expect(instance.options.secret_access_key).to eq "URL_SECRET_ACCES_KEY"
        end
      end
      context "when options are passed" do
        it "overrides ENVOKU_URL keys" do
          set_default_aws_keys
          set_envoku_aws_keys
          set_valid_envoku_url
          instance = Envoku::Adapters::S3.new(
            bucket_name: 'test-bucket',
            access_key_id: 'test-access-key-id',
            secret_access_key: 'test-secret-access-key',
          )
          instance.send(:apply_environment_options)
          expect(instance.options.bucket_name).to eq 'test-bucket'
          expect(instance.options.access_key_id).to eq "test-access-key-id"
          expect(instance.options.secret_access_key).to eq "test-secret-access-key"
        end
      end
    end
  end

end
