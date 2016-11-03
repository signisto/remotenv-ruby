describe Envoku do
  describe "::logger" do
    it "assigns a default logger" do
      Envoku.instance_variable_set(:"@_logger", nil)
      expect(Envoku.logger).to be_a(Envoku::Logger)
    end
    it "proxies to @_logger" do
      Envoku.instance_variable_set(:"@_logger", :some_logger)
      expect(Envoku.logger).to eq(:some_logger)
    end
  end


  describe "::logger=" do
    it "assigns @_logger" do
      logger = Envoku::Logger.new(STDOUT)
      Envoku.logger = logger
      expect(Envoku.logger).to eq(logger)
      expect(Envoku.instance_variable_get(:"@_logger")).to eq(logger)
    end
  end
end


describe Envoku::Logger do
  describe "#initialize" do
    context "ENV['LOG_LEVEL'] = info" do
      it do
        ENV['LOG_LEVEL'] = "info"
        logger = Envoku::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
    context "ENV['LOG_LEVEL'] = warn" do
      it do
        ENV['LOG_LEVEL'] = "warn"
        logger = Envoku::Logger.new(STDOUT)
        expect(logger.level).to eq(2)
      end
    end
    context "ENV['ENVOKU_LOG_LEVEL'] = warn" do
      it do
        ENV['LOG_LEVEL'] = "warn"
        logger = Envoku::Logger.new(STDOUT)
        expect(logger.level).to eq(2)
      end
    end
    context "ENV['LOG_LEVEL'] = warn   ENV['ENVOKU_LOG_LEVEL'] = debug" do
      it do
        ENV['LOG_LEVEL'] = "warn"
        ENV['ENVOKU_LOG_LEVEL'] = "debug"
        logger = Envoku::Logger.new(STDOUT)
        expect(logger.level).to eq(0)
      end
    end
    context "ENV['LOG_LEVEL'] = nil" do
      it do
        ENV['LOG_LEVEL'] = nil
        logger = Envoku::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
    context "ENV['LOG_LEVEL'] = X" do
      it do
        ENV['LOG_LEVEL'] = "X"
        logger = Envoku::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
    context "ENV['LOG_LEVEL'] = VERSION" do
      it do
        ENV['LOG_LEVEL'] = "VERSION"
        logger = Envoku::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
    context "ENV['LOG_LEVEL'] = :blank" do
      it do
        ENV['LOG_LEVEL'] = ""
        logger = Envoku::Logger.new(STDOUT)
        expect(logger.level).to eq(1)
      end
    end
  end
end
