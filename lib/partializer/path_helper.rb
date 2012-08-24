class Partializer
  module PathHelper
    def to_partial_path
      context = self.respond_to? :partials ? self.partials : self
      unless context.respond_to? :view_path
        raise ArgumentError, "Must have a #view_path method: #{self}"
      end
      context.view_path
    end
  end
end