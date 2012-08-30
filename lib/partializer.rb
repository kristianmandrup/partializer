# require 'active_support/core_ext/string'
# require 'active_support/inflector'
require 'rails'
require 'hashie'

require 'partializer/view_helper'
require 'partializer/engine' if defined?(::Rails::Engine)

class Partializer
  autoload :Collection,   'partializer/collection'
  autoload :Resolver,     'partializer/resolver'
  autoload :Partials,     'partializer/partials'
  autoload :PathHelper,   'partializer/path_helper'

  class InvalidPartialError < StandardError; end

  def partials_for name, *args
    hash = args.flatten.inject({}) do |res, arg|
      key = arg.kind_of?(Hash) ? arg.keys.first : arg
      res[key.to_sym] = self.class.resolve(arg)
      res
    end
    Partializer::Collection.new name, hash.keys, hash
  end

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

    def partializer name, options = {}, &block
      default_parent = ::Partializer

      parent = options[:parent] || default_parent
      raise ArgumentError, "Parent must have a partialize method, was: #{parent}" unless parent.respond_to? :partialize

      clazz_name = name.to_s.camelize
      context = self.kind_of?(Class) ? self : self.class

      clazz = parent ? Class.new(parent) : Class.new
      context.const_set clazz_name, clazz          
      clazz = context.const_get(clazz_name)

      clazz.instance_eval(&block) if block_given?
      clazz
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