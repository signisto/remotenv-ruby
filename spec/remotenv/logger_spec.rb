describe Remotenv do
  describe "::logger" do
    it "assigns a default logger" do
      Remotenv.instance_variable_set(:"@_logger", nil)
      expect(Remotenv.logger).to be_a(Remotenv::Logger)
    end
    it "proxies to @_logger" do
      Remotenv.instance_variable_set(:"@_logger", :some_logger)
      expect(Remotenv.logger).to eq(:some_logger)
    end
  end


  describe "::logger=" do
    it "assigns @_logger" do
      logger = Remotenv::Logger.new(STDOUT)
      Remotenv.logger = logger
      expect(Remotenv.logger).to eq(logger)
      expect(Remotenv.instance_variable_get(:"@_logger")).to eq(logger)
    end
  end
end


describe Remotenv::Logger do
  describe "#initialize" do
    context "ENV['LOG_LEVEL'] = info" do
      it do
        ENV['LOG_LEVEL'] = "info"
        logger = Remotenv::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
    context "ENV['LOG_LEVEL'] = warn" do
      it do
        ENV['LOG_LEVEL'] = "warn"
        logger = Remotenv::Logger.new(STDOUT)
        expect(logger.level).to eq(2)
      end
    end
    context "ENV['REMOTENV_LOG_LEVEL'] = warn" do
      it do
        ENV['LOG_LEVEL'] = "warn"
        logger = Remotenv::Logger.new(STDOUT)
        expect(logger.level).to eq(2)
      end
    end
    context "ENV['LOG_LEVEL'] = warn   ENV['REMOTENV_LOG_LEVEL'] = debug" do
      it do
        ENV['LOG_LEVEL'] = "warn"
        ENV['REMOTENV_LOG_LEVEL'] = "debug"
        logger = Remotenv::Logger.new(STDOUT)
        expect(logger.level).to eq(0)
      end
    end
    context "ENV['LOG_LEVEL'] = nil" do
      it do
        ENV['LOG_LEVEL'] = nil
        logger = Remotenv::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
    context "ENV['LOG_LEVEL'] = X" do
      it do
        ENV['LOG_LEVEL'] = "X"
        logger = Remotenv::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
    context "ENV['LOG_LEVEL'] = VERSION" do
      it do
        ENV['LOG_LEVEL'] = "VERSION"
        logger = Remotenv::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
    context "ENV['LOG_LEVEL'] = :blank" do
      it do
        ENV['LOG_LEVEL'] = ""
        logger = Remotenv::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
  end
end
