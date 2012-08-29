class Partializer
  module Rails
    class Engine < ::Rails::Engine
      initializer 'partializer' do 
        ActionView::Base.send :include, ::Partializer::ViewHelper
      end
    end
  end
end