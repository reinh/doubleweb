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

    module Equivocable
      def hash
        [self.class, 0, *hash_attrs].map(&:hash).reduce(:^)
      end

      def eql?(other)
        hash == other.hash
      end

      def ==(other)
        hash_attrs = other.hash_attrs
      end

      protected
      def hash_attrs
        raise NotImplementedError, "define 'hash_attrs' to provide #hash, #eql? and #== semantics"
      end

    end

    module RequestPatch
      include Equivocable

      protected
      def hash_attrs
        [path, method, body]
      end

    end

    module ResponsePatch
      include Equivocable

      protected
      def hash_attrs
        [code, @version, message]
      end

    end

  end
end
