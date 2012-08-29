class Partializer
  class Partial
    attr_reader :path, :name, :ns, :action

    def initialize path, name
      @path = path unless path.blank?
      self.name = name
    end

    def path= path_name      
      raise ArgumentError, "Path is blank" if path_name.blank?
      @path = path_name.gsub /\\./, '/' 
      normalize!
    end

    def name= name
      @name = name
      normalize!
    end

    def view_path
      [ns, action, path, name].compact.join('/')
    end
    
    def to_partial_path
      view_path.gsub('.', '/')
    end

    protected

    def set_context ns, action
      @ns, @action = [ns, action]
      self
    end

    def normalize!
      if path =~ /\.#{name}$/
        norm = path.split('.')[0..-2].join('.')
        @path = norm unless norm.blank? 
      end
    end
  end
end