module Partializers
  class Properties < Partializer
    class Show < Partializer
      partials_for :main, [{upper: :gallery}, :lower]
        
      partials_for :side, [:basic_info, :cost, :more_info, :period, :similar_properties]

      class Lower < Partializer
        class Communication < Partializer
          partialize :profile, :contact_requests, :social, :favorite, :priority_subscription, :free_subscription, :comments
        end

        partialize :_communication, :description
      end

      partials_for :my_main,  [{upper: :gallery}, :_lower]      
    end
  end
end