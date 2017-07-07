module Remotenv
  module Adapters
    module_function

    def for(uri)
      if uri.scheme == 'http' || uri.scheme == 'https'
        Remotenv::Adapters::Http.new(uri)
      elsif uri.scheme == 's3'
        Remotenv::Adapters::S3.new(uri)
      else
        raise "Could not find adapter for scheme - #{uri.scheme}"
      end
    end
  end
end
