module DoubleWeb::Caches::Yaml

  include DoubleWeb::Caches::Base

  class Store
    require 'yaml'
    require 'zaml' # YAML.dump is broken
    require 'singleton'
    include Singleton
    attr_accessor :path

    def clear
      dump({}) if path?
    end

    def []=(request, response)
      dump(load.merge(request => response))
    end

    def [](request)
      p self.load
      self.load[request]
    end

    private

    def open(mode, &block)
      File.open(path, mode, &block)
    end

    def dump(object)
      open('w') {|fh| fh.write ZAML.dump(object) }
    end

    def load
      clear unless exists?
      open('r') {|fh| YAML.load(fh) } || {}
    end

    def path?; path end
    def exists?; path? && File.exists?(path) end
  end

  def self.cache; Store.instance end
end
