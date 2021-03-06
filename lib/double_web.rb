module DoubleWeb

  module DriverPatches
    autoload :NetHTTP, 'double_web/driver_patches/net_http'
  end

  module Caches
    autoload :Base, 'double_web/caches/base'
    autoload :Memory, 'double_web/caches/memory'
    autoload :Yaml, 'double_web/caches/yaml'
  end

  class UnexpectedRequestError < StandardError; end

  def self.init!
    case ENV['internet']
    when 'on'    then puts "DoubleWeb: inactive"; clear!
    when 'off'   then puts "DoubleWeb: playback mode"; playback!
    when 'watch' then puts "DoubleWeb: watching"; watch!
    else
      puts "DoubleWeb: set the `internet` enviroment variable to control DoubleWeb",
           "  options are 'on', 'off', 'watch'",
           "  DoubleWeb is currently disabled."
    end
  end

  def self.patch!
    unless @patched
      require 'net/http' unless defined?(Net::HTTP)
      Net::HTTP.send(:include, DoubleWeb::DriverPatches::NetHTTP)
      Net::HTTPRequest.send(:include, DoubleWeb::DriverPatches::NetHTTP::RequestPatch)
      Net::HTTPResponse.send(:include, DoubleWeb::DriverPatches::NetHTTP::ResponsePatch)
    end
    @patched = true
  end

  def self.watch!
    patch!
    @watch = true
    if block_given?
      res = yield
      @watch = false
      res
    end
  end

  def self.unwatch!
    @watch = false
  end

  def self.watch?
    @watch
  end

  def self.playback!
    patch!
    @playback = true
    if block_given?
      res = yield
      @playback = false
      res
    end
  end

  def self.stop_playback!
    @playback = false
  end

  def self.playback?
    @playback
  end

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

  def self.[](request)
    cache[request]
  end

  def self.[]=(request, response)
    cache[request] = response
  end

end
