class Partializer
  module Resolver
    def create_partializer name
      context = self.kind_of?(Class) ? self : self.class
      clazz = "#{context.name}::#{name.to_s.camelize}".constantize
      clazz.new
    end

    def resolve arg
      case arg
      when Hash
        resolve_hash(arg)
      when String, Symbol
        resolve_sym(arg)
      when Partializer::Collection
        arg
      else
        raise ArgumentError, "Could not partialize: #{arg}"
      end
    end

    def resolve_hash hash
      Partializer::Collection.new 'hash', hash.keys, hash
    end

    # Creates a Collection from a Symbol
    # :gallery
    # gallery -> :gallery
    # partials: [:gallery]
    def resolve_sym arg
      value = resolve_value arg
      arg = arg.to_s.sub(/^_/, '')
      if value.to_s == arg.to_s
        Partializer::Collection.new 'sym', arg
      else
        Partializer::Collection.new 'sym', arg, {arg.to_sym => value}
      end
    end

    # a Partializer or a sym!
    def resolve_value arg
      arg = arg.to_s
      arg[0] == '_' ? resolve_partializer(arg) : arg.to_sym
    end

    def resolve_partializer arg
      arg.sub!(/^_/, '')
      instance = create_partializer(arg)
      {instance.class.name.to_s.demodulize.underscore => instance.partials}
    end
  end
end