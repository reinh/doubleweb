module DoubleWeb::Playback
  def playback!
    patch!
    @playback = true
    if block_given?
      res = yield
      @playback = false
      res
    end
  end

  def stop_playback!
    @playback = false
  end

  def playback?
    @playback
  end
end
