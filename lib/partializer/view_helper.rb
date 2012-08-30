class Partializer
  module ViewHelper
    def partialize *args, &block
      case args.size
      when 2
        subject = args.first
        path = args.last
      when 1
        path = args.first
        subject = partializer
      else
        raise ArgumentError, "partialize takes 1 or 2 args, was: #{args}"
      end

      parts = case subject
      when String
        subject.split('#')
      when Partializer::Collection
        [subject.ns, subject.action]
      end

      name = parts.first
      action = parts.last
      try_clazzes = [name.to_s.camelize, "Partializers::#{name.to_s.camelize}"]

      clazz = try_clazzes.select do |clazz|
        begin
          clazz.constantize
        rescue NameError
          nil
        end
      end.first

      unless clazz
        raise ArgumentError, "No Partializer could be found for: #{subject} in: #{try_clazzes}"
      end
      
      instance = clazz.constantize.new
      instance = instance.send(action)

      path.split('.').each do |meth|
        instance = instance.send(meth)
      end
      instance.set_context *parts
      instance
    end

    def render_partials subject, options = {}
      partials = case subject
      when Partializer::Collection
        subject.partials
      else
        subject
      end

      unless partials.kind_of? Partializer::Partials
        raise ArgumentError, "Must be a Partializer::Collection or Partializer::Partials, was: #{collection}"
      end

      # make partializer available as object in partial called
      locals_opts = {locals: {:partializer => subject}}.merge(options[:locals] || {})
      options.merge! locals_opts

      # render options.merge(:partial => partials)
      partials.list.inject("") do |res, partial|
        opts = {:partial => partial.to_partial_path}.merge(options)
        res += raw(render opts)
        # res += "#{opts.inspect} ------- "
      end.html_safe
    end
  end
end