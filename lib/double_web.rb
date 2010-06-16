module DoubleWeb
  autoload :Patch, 'double_web/patch'
  autoload :Playback, 'double_web/playback'
  autoload :Watch, 'double_web/watch'

  module DriverPatches
    autoload :NetHTTP, 'double_web/driver_patches/net_http'
  end

  module Caches
    autoload :Base, 'double_web/caches/base'
    autoload :Memory, 'double_web/caches/memory'
    autoload :Yaml, 'double_web/caches/yaml'
  end

  extend Patch
  extend Watch
  extend Playback
  extend Caches::Base

  class UnexpectedRequestError < StandardError; end

  def self.clear!
    unwatch!
    stop_playback!
    cache.clear
  end

  def self.cache_strategy=(strategy)
    @cache_strategy = {
      :memory => DoubleWeb::Caches::Memory,
      :yaml => DoubleWeb::Caches::Yaml
    }[strategy]
  end

  def self.cache
    (@cache_strategy ||= DoubleWeb::Caches::Memory).cache
  end

end
