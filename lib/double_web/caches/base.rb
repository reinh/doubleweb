module DoubleWeb::Caches::Base
  def cache
    raise NotImplementedError, "cache not implemented"
  end

  def [](request)
    cache[request]
  end

  def []=(request, response)
    cache[request] = response
  end
end

