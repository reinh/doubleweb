module DoubleWeb::Caches::Memory
  include DoubleWeb::Caches::Base

  class Store < Hash
    require 'singleton'
    include Singleton
  end

  def self.cache; Store.instance end
end
