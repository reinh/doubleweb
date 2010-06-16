module DoubleWeb::DriverPatches
  module NetHTTP
    def self.included(klass)
      klass.send :alias_method, 'request_without_doubleweb', 'request'
      klass.send :alias_method, 'request', 'request_with_doubleweb'
    end

    def request_with_doubleweb(request, body = nil, &block)
      if DoubleWeb.playback?
        DoubleWeb[request] or raise DoubleWeb::UnexpectedRequestError
      else
        response = request_without_doubleweb(request, body, &block)
        if DoubleWeb.watch?
          DoubleWeb[request] = response
        end
        response
      end
    end
  end
end

