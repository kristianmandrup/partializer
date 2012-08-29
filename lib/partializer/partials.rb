require 'partializer/partial'

class Partializer
  class Partials
    include Enumerable
    
    attr_reader :name

    def initializer list
      @list = list
    end

    def << *partials
      @list ||= []
      partials.flatten.each do |partial_name|        
        partial = Partializer::Partial.new(path, partial_name)
        @list << partial
      end
    end

    alias_method :path, :name
    
    def to_partial_path
      path.gsub('.', '/')
    end

    def list
      @list ||= []
    end

    def each &block
      list.each {|item| yield item.name }
    end

    def set_context ns, action
      list.each {|p| p.send :set_context, ns, action }
    end
  end
end