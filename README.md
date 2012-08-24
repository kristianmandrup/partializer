## Partializer

Structure your partials!

```ruby
module Partializers
  class Properties < Partializer
    class Show < Partializer
      def main
        partials_for [{upper: :gallery}, :lower, :bar]
      end

      def side
        partials_for [:basic_info, :cost, :more_info, :period, :similar_properties]
      end

      class Lower < Partializer
        class Communication < Partializer
          partialize :profile, :contact_requests, :social, :favorite, :priority_subscription, :free_subscription, :comments
        end

        partialize :_communication, :description        
      end
    end
  end
end
```

```haml
#communication.column
  = render partial: p = partialize('properties#show', 'main.lower.communication'), locals: {p: p}
```

```haml
#communication.column
  = render_partials partialize('properties#show', 'main')
```

Will render fx `properties/show/main/upper` and `properties/show/main/lower`.
The partial called will have the partializer passed in as a local.

This allows you to continue calling like this, which will effectively be a shorthand for calling: 

`= render_partials partialize('properties#show', 'main.lower')`

```haml
#main.column
  = render_partials partialize(partializer, 'lower')
```

## Hidden Rails feature

I'm taking advantage of this little hidden 'gem' in Rails :)

[hidden-features-in-rails-3-2](http://blog.plataformatec.com.br/2012/01/my-five-favorite-hidden-features-in-rails-3-2/)

Imagine your application have an activity feed and each activity in the feed has a certain type. Usually, each type is rendered differently. For example, if you consider a to-do-list application, activities could be both “marking a list as favorite” or “marking a task as done”. Usually, applications solve this by looping for each item and rendering its respective partial, something like this:

```ruby
@activities.each do |activity|
  render :partial => "activities/#{activity.kind}",
    :locals => { :activity =>  activity }
end
```

Now, you can solve this problem by defining to_partial_path in the model (the method to_partial_path is part of the ActiveModel API and can be implemented in any object. The example above implements it in the model for convenience, but it could be a presenter, another ORM, etc):

```ruby
class Activity
  def to_partial_path
    "activities/#{kind}" 
  end
end
```

And then invoking:

`render :partial => @activities, :as => :activity`


## Contributing to partializer
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Kristian Mandrup. See LICENSE.txt for
further details.

