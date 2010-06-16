module DoubleWeb::Patch
  def patch!
    unless @patched
      require 'net/http' unless defined?(Net::HTTP)
      Net::HTTP.send(:include, DoubleWeb::DriverPatches::NetHTTP)
    end
    @patched = true
  end
end
