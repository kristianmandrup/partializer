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
  - [:upper :lower].each do |name|
    = render partial: "properties/show/main/#{name}"
```

```haml
#lower.column
  - [:communication :description].each do |name|
    = render partial: "properties/show/main/lower/#{name}"
```

```haml
#communication.column
  - [:profile, :contact_requests, :social, :favorite, :comments].each do |name|
    = render partial: "properties/show/main/lower/communication/#{name}"
```

Note also that all the partial paths are hardcoded here. If I move a folder, all the partials withing this folder have to be reconfigured to the new location! Argh!

## With partialized partials :)

Imagine you have a `properties/show/_main` partial. Then you can render all its subpartials like this:

```haml
#main.column
  = render_partials partialize('properties#show', 'main')
```

For the `properties/show/main/_lower` partial, simply:

```haml
#lower.column
  = render_partials partialize(partializer, 'lower')
```

And for the `properties/show/main/lower/_communication` partial, simply:

```haml
#communication.column
  = render_partials partialize(partializer, 'communication')
```

Since the partializer (with previous context) will be passed down as a local and used by `partialize` to resolve the context (partial path). Sleek :)

### The REAL power!

Since the Partializer is class based, you can use simple inheritance and include to mixin partial configurations for other contexts, override, call `super` etc.

Another great advantage is, that if you pass the "context" down the partial hierarchy, changing the top level context will take effect on all the partials in the call hierarchy. One change fix!

## Configuration

Note: This should be improved with even better DSL and perhaps loading from YAML file or similar? Maybe even supplying a hash directly and using Hashie::Mash?

Structure your partial groupings like this:

```ruby
module Partializers
  class Properties < Partializer
    class Show < Partializer
      partials_for :main, [{upper: :gallery}, :lower]
        
      partials_for :side, [:basic_info, :cost, :more_info, :period]

      partializer :lower do
        partializer :communication do
          partialize :profile, :contact_requests, :social, :favorite, :priority_subscription, :free_subscription, :comments
        end

        partialize :_communication, :description
      end

      partials_for :my_main,  [{upper: :gallery}, :_lower]      
    end
  end
end
```

Alternatively using Classes and methods (sth like):

```ruby
module Partializers
  class Properties < Partializer
    class Show < Partializer
      def main
        partials_for :main, [{upper: :gallery}, :lower]
      end
        
      def side
        partials_for :side, [:basic_info, :cost, :more_info, :period]
      end

      class Lower < Partializer
        class Communication < Partializer
          def partials 
            partials_for [
              :profile, :contact_requests, :social, 
              :favorite, :priority_subscription, 
              :free_subscription, :comments
            ]
          end
        end

        def partials
          partials_for [:_communication, :description]
        end
      end

      def my_main
        partials_for [{upper: :gallery}, :_lower]
      end
    end
  end
end
```

This will likely be optimized in the near future. No need for the `partials_for` method call in the instance methods. Can be auto-resolved when the Partializer resolves itself into a nested `Partializer::Collections` structure.

## Special Conventions

A Symbol prefixed with underscore will nest down the hierarchy, see fx `:_lower`vs `:lower`. In this case, the class must have been defined, since it uses a constant lookup on the class and instantiates it.

It might make sense to drop this `_` convention and simply always attempt nested resolution?

## Usage in Views and Partials

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

Now, you can solve this problem by defining `to_partial_path` (part of the ActiveModel API) and can be implemented in any object. 

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

