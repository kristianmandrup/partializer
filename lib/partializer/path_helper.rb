class Partializer
  module PathHelper
    def partial_path name
      return File.join(to_partial_path, name.to_s) if partials.include? name.to_sym
      raise Partializer::InvalidPartialError, "the partial #{name} is not registered for this Partializer"
    end    

    def build_path path
      raise ArgumentError, "Must take a path argument" unless path
      File.join(to_partial_path, path.to_s.gsub('.', '/'))
    end
  end
end