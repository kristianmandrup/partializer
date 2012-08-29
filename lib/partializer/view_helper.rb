class Partializer
  module ViewHelper
    def partialize subject, path, &block
      parts = case subject
      when String
        subject.split('#')
      when Partializer::Collection
        [subject.ns, subject.action]
      end

      name = parts.first
      action = parts.last
      clazz = "Partializers::#{name.to_s.camelize}".constantize
      instance = clazz.new
      instance = instance.send(action)

      path.split('.').each do |meth|
        instance = instance.send(meth)
      end
      instance.set_context *parts
      instance
    end

    def render_partials subject, options = {}
      partials = subject.respond_to?(:partials) ? subject.partials : subject
      unless partials.kind_of? Partializer::Partials
        raise ArgumentError, "Must be a Partializer::Collection or Partializer::Partials, was: #{collection}"
      end

      # make partializer available as object in partial called
      locals_opts = {locals: {:partializer => subject}}.merge(options[:locals] || {})
      options.merge! locals_opts

      partials.list.inject("") do |res, partial|
        # res += "#{partial.view_path}:"
        opts = {:partial => subject}.merge(options)
        res += raw(render opts)
      end
    end
  end
end