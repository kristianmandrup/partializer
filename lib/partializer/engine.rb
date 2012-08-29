class Partializer
  module Rails
    class Engine < ::Rails::Engine
      initializer 'partializer' do 
        ActiveView::Base.send :include, ::Partializer::ViewHelper
      end
    end
  end
end