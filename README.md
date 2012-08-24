## Partializer

Structure your partials in Rails 3+

## Installation

```ruby
# Gemfile
gem 'partializer'
```

Console, run:

`$ bundle`

## Requirements

Only tested on Ruby 1.9.3 and Rails 3.2.

## Why?

In a Rails project I notices this reoccuring pattern and thought it would be nice to encapsulate it better ;)

```haml
#communication.column
  - [:profile, :contact_requests, :social, :favorite, :priority_subscription, :free_subscription, :comments].each do |name|
  = render partial: "properties/show/communication/#{name}"
```

Imagine you have a `properties/show/_main` partial. Then you can render all its subpartials like this:

```haml
#communication.column
  = render_partials partialize('properties#show', 'main')
```

And for the `properties/show/main/_lower` partial, simply:

```haml
#main.column
  = render_partials partialize(partializer, 'lower')
```

Since the partializer (with context) will be passed down as a local. Sleek :)

## Configuration

Note: This should be improved with even better DSL and perhaps loading from YAML file or similar? Maybe even supplying a hash directly and using Hashie::Mash?

Structure your partial groupings like this:

```ruby
module Partializers
  class Properties < Partializer
    class Show < Partializer
      partials_for :main, [{upper: :gallery}, :lower]
        
      partials_for :side, [:basic_info, :cost, :more_info, :period]

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
```

Note: A Symbol prefixed with underscore will nest down the hierarchy, see fx `:_lower`vs `:lower`. In this case, the class must have been defined, since it uses a constant lookup on the class and instantiates it.

Now you can use the Partializers in your views!

```haml
#communication.column
  = render_partials partialize('properties#show', 'main')
```

This will render fx `properties/show/main/upper` and `properties/show/main/lower`.
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

