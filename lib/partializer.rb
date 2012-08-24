# require 'active_support/core_ext/string'
# require 'active_support/inflector'
require 'rails'
require 'hashie'

require 'partializer/path_helper'
require 'partializer/partials'
require 'partializer/collection'
require 'partializer/resolver'

require 'partializer/view_helper'

class Partializer
  class << self
    def partialize *args, &block
      name = self.name.to_s.underscore

      hashie = args.flatten.inject({}) do |res, arg|
        item = resolve_value(arg)
        res.merge! Hashie::Mash.new arg.to_sym => item
      end

      collection = Partializer::Collection.new name, args, hashie

      define_method :partials do
        @partials ||= collection # Partializer::Collection.new hashie, partials
      end
    end

    def partials_for name, *args      
      hash = args.flatten.inject({}) do |res, arg|
        key = arg.kind_of?(Hash) ? arg.keys.first : arg
        res[key.to_sym] = resolve(arg)
        res
      end
      define_method name do
        Partializer::Collection.new name, hash.keys, hash
      end
    end


    protected

    include Resolver

    def partialize_item_of hash
      matching?(hash) ? hash.values.first.to_sym : hash
    end

    def matching? hash
      hash.keys.first.to_sym == hash.values.first.to_sym
    end

  end

  protected

  include Resolver

  def method_missing meth_name, *args, &block    
    instance = create_partializer(meth_name)
    instance.respond_to?(:partials) ? instance.partials : instance
  end
end