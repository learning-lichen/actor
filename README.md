# Actor

[![Build Status](https://travis-ci.org/maxgale/actor.svg?branch=master)](https://travis-ci.org/maxgale/actor)

The actor gem provides a completely implicit implementation of the actor pattern. The goal of the library is to provide an easy way to implement fast, concurrent code without having to worry about race conditions or unexpected side-effects.

## Installation

Add this line to your application's Gemfile:

    gem 'actor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install actor

## Usage

### Actors

    require 'actor/base'

    class MyActor
      include Actor::Base

      def example_method
        'hi'
      end
    end

    my_actor = MyActor.new

That's it! Now any interations with `my_actor` will be executed concurrently. It's also worth noting that there are no real method invocations and there are no return values. Instead, code is executed via message passing. Instead of return values, there are callbacks.

### Callbacks

    my_actor.before_action :example_method do
      # Code here is executed before :example_method is executed by the actor
      puts 'before'
    end

    my_actor.after_action :example_method do |result|
      # Code here is executed after :example_method is executed by the actor
      puts 'after'
      puts result
    end

    my_actor.example_method

    => before
    => after
    => hi

### Timers

Another useful feature is the timer. The timer is an object that periodically executes from code.

    require 'actor/timer'

    # Create a timer the executes every 1/30th of a second. Only executes twice.
    Actor::Timer.new 0.033, 2 do
      puts 'hi'
    end

    => hi
    => hi

Passing in `0` as the number of iterations to the timer causes it to execute indefinitely. You can also pause, resume, and wait for timers to finish execution.

    my_timer = Timer.new 0.033, 0 do
      # Do periodic work
    end

    my_timer.pause # Temporarily stop work

    my_timer.resume # Resume the work

    my_timer.wait # Since `iterations = 0`, this will block forever

## Gotchas

Unfortunately, there are a few "gotchas" when using this gem.

1. `Actor::Base` overrides the including class's `:new` method and renames it to `:__actor_new`. This sets up the possibility of naming conflicts.
2. When creating a new actor, the actual instance is wrapped in a proxy class.  This proxy forwards all methods to the instance to be executed in a concurrent way. This means it is impossible to execute code non-concurrently when handling the proxy. You can access the underlying instance by calling `__proxy_target`  on the proxy. Note: No callbacks when accessing the instance directly (unless you use send).
3. The actor has an overriden send method. This means that using `:send` will always execute code concurrently, no matter what, and will also trigger callbacks.
4. The timer period is counted from the end of the last block to the start of the next block. This means that the timer firing is very approximate and definitely not designed for blocking code.

## Todo

1. Using a thread pool would be nice.
2. Benchmarks comparing MRI 2.1.2 vs. Rubinisu 2.2.6.
3. Benchmarks comparing of this gem vs. Celluloid
5. Add a way of using actors over a network via RPC

## Contributing

1. Fork it ( https://github.com/maxgale/actor/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
