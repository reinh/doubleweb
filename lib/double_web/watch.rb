module DoubleWeb::Watch
  def watch!
    patch!
    @watch = true
    if block_given?
      res = yield
      @watch = false
      res
    end
  end

  def watch?
    @watch
  end

  def unwatch!
    @watch = false
  end
end
