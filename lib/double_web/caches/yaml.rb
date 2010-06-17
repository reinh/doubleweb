module DoubleWeb::Caches::Yaml
  include DoubleWeb::Caches::Base

  class Store
    require 'yaml'
    require 'singleton'
    include Singleton
    attr_accessor :path

    def clear
      dump({}) if path?
    end

    def []=(key, value)
      dump(load.merge(key => value))
    end

    def [](key)
      load[key]
    end

    private

    def open(mode, &block)
      raise "Set DoubleWeb.cache.path to use YAML storage" unless path
      File.open(path, mode, &block)
    end

    def dump(object)
      open('w') {|fh| YAML.dump(object, fh) }
    end

    def load
      clear unless exists?
      YAML.load_file(fh) || {}
    end

    def path?; path end
    def exists?; path? && File.exists?(path) end
  end

  def self.cache; Store.instance end
end
