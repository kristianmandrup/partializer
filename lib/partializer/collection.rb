class Partializer
  class Collection
    include Enumerable

    include Partializer::PathHelper

    attr_reader :hashie, :name, :ns, :action

    def initialize name, *items
      hash = items.extract_options!      
      partials << partial_keys(items)
      self.name = name.to_s
      @hashie = Hashie::Mash.new resolve(hash) unless hash.empty?
      set_names unless hashie.nil?
    end

    def each &block
      partials.each {|partial| yield partial }      
    end

    def partials
      @partials ||= Partializer::Partials.new
    end

    def path
      [ns, action, name.gsub('.', '/')].compact.join('/')
    end

    def set_context ns, action
      @ns, @action = [ns, action]
      partials.list.each {|p| p.send :set_context, ns, action }
    end

    protected

    def name= name
      @name = name
      partials.list.each do |p|
        p.path = name
      end
    end

    def set_names
      hashie.keys.each do |key|
        if key.kind_of?(String)
          h = hashie.send(key)
          if h.kind_of? Partializer::Collection
            h.send :name=, "#{name}.#{key}"
            h.set_names unless h.hashie.nil?
          end
        end
      end
    end

    def resolve hash
      hash.inject({}) do |res, pair|
        key = pair.first
        item = pair.last
        key = key.to_s.sub(/^_/, '').to_sym

        value = resolve_value key, item        
        
        res[key.to_s.sub(/^_/, '').to_sym] = value
        res
      end
    end

    def resolve_value key, item
      case item
      when Partializer::Collection
        item.hashie ? item.send(key) : item
      when Symbol, String
        Partializer::Collection.new('noname', item)
      when Hash
        item.values.first
      else
        raise ArgumentError, "cant resolve: #{item.inspect}"
      end
    end

    def partial_keys *args
      args.flatten.map do |item| 
        case item
        when Hash
          item.keys.map(&:to_sym)
        when String, Symbol
          item.to_s.sub(/^_/, '').to_sym
        end
      end.flatten.compact.uniq
    end    

    def method_missing meth_name, *args, &block
      hashie.send(meth_name)
    end    
  end
end