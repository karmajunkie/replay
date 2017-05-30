# Replay
Replay is a gem to support event sourcing data within domain boundaries. With event sourced data, the application stores data as a series of domain events, which are applied to the domain object in order to mutate state.

## Disclaimer (5/30/2017)
This repo is here primarily for historical reasons—if you are starting a new project in Ruby and want to eventsource some of your data, I recommend checking out [Eventide Project](https://github.com/eventide-project) and the various libraries that make up that project, which is (as of this writing) under active development by individuals who are much more concerned than I am with moving Ruby forward in that direction. 

### CQRS/ES 30 second intro
[Command Query Responsibility Segregation](http://codebetter.com/gregyoung/2010/02/16/cqrs-task-based-uis-event-sourcing-agh/) (and [Fowler's explanation](http://martinfowler.com/bliki/CQRS.html) is a pattern popularized by Greg Young and Udi Dahan from within the sphere of Domain Driven Design. The general idea is that within domain models, objects are rarely good at both representing truth and being purposeful for queries and reporting, and therefore we should separate the responsibilities.  

[Event Sourcing](http://martinfowler.com/eaaDev/EventSourcing.html) is a pattern that is not required by (but pairs extremely well with) CQRS. However, by embracing this pattern a system can adapt to new reporting and query requirements at any time with a great deal of flexibility, and the use of messaging/pub-sub along with events creates an easy path to breaking apart monolithic applications and separating domains.

### A short example

    class ReplayExample
      include Replay::Publisher
      
	    #define events
      events do
        SomethingHappened(name: String, pid: Integer)
        SomethingElseHappened(pid: Integer)
        #....
      end
     
      #applying events (changing state)
      apply SomethingHappened do |event|
        @name = event.name
        @pid  = event.pid
      end
      
      apply SomethingElseHappened do |event|
        @state = :happened_again
        @pid = nil if event.pid == @pid
      end
      
      def do_something(pid = nil)
        #the command validates inputs
        #InvalidCommand is defined by the application
        raise InvalidCommand.new("parameters were invalid") unless pid
        
        #publish events
        publish SomethingHappened.new(:name = "foo", :pid => pid)

        #publish with method syntax
        publish SomethingElseHappened(pid: pid)
      end
    end

There's a couple of things to note about the above example.  ReplayExample is a domain object. (Clearly this example is a bit contrived.) [Domain objects](http://martinfowler.com/eaaCatalog/domainModel.html) represent and encapsulate domain logic in its purest sense. No application code should make its way into a domain object, nor should concerns from another bounded context.

Domain objects publish events in order to mutate state.  The events published by this domain object are defined within the `events` block; `ReplayExample::SomethingHappened` is a class defined there, which has two attributes `name` and `pid`, which are `String` and `Integer` respectively. Events may also be defined manually, like any other class. Because they're essentially value objects, with zero behavior, the shorthand form above is usually going to be easier.

`ReplayExample` instances change state by applying events. These events are handled in the `apply` blocks in the above example (you see what I did there?) This part is, mostly, really simple. You probably did a lot of this state thing in your freshman programming class. More on that later.

So if we've got the events defined, and we know what events change state in which ways, where do they come from? Commands, of course. The role of a command is to validate its inputs and publish the events if the command is valid. That's it. No changing state allowed there—seriously, none. Ever heard the term [snowflake server](http://martinfowler.com/bliki/SnowflakeServer.html)? Break the state rule and you're going to have snowflake instances and weird bugs.

Commands are the art and science of CQRS. In the above example, I've implemented it as a method on the domain object (which is also called an aggregate root in the language of DDD.) Its just as frequently done as a class, e.g.

    class ReplayExample::DoSomething
       include Replay::Publisher

       def initialize(name, pid=nil)
          raise InvalidCommand.new unless pid
          @name = name
          @pid = pid
       end
       
       def perform
         #the publish the event, but don't raise an error if an application block can't be found
         publish ReplayExample::SomethingHappened.new(name: @name, pid: @pid), false
       end
    end

    ReplayExample::DoSomething.new("foo", 123).perform

The above command class performs the same function, but has some advantages. In a Rails application, you can mix in ActiveModel::Validations to get ActiveRecord-style validators on it. You can also use Virtus (recommended) or ActiveModel to make it ActiveModel compliant and use it as a form object. This pattern is especially useful when you're dealing with non-domain services (e.g. credit card processors.) You can publish events from any model; there's nothing special about that (though its best if you don't do it without good reason, or you'll subvert one of the great advantages of DDD—separation of bounded contexts).

## Digging deeper

### The Repository
The Repository is an application-defined object (replay will generate one for you) which will load your domain objects from storage. The repository's job is to find the event stream requested and apply the events from the event stream to a newly created object of the supplied type. Every application has at least one repository, and may have several.

Use it like so:
    
    example = Repository.load(ReplayExample, some_guid)

What you'll get back is a newly initialized instance of your object, with all events from the stream applied in sequence. By default, if it doesn't find any events for that stream identifier, it will raise an exception; you can change this behavior by supplying `:create => false` or `:create => true` to `load`. When false, the Repository will not attempt to create the instance. If true, and the object defines a `create` method that takes no parameters, the default implementation will call `create`. (Its standard practice for that method to publish a `Created` event.)

Your application's repository will look something like this:

    class Repository
      include Replay::Repository

      configure do |config|
        config.store = :active_record
        config.add_default_subscriber EventLogger
      end
    end

You can also create a repository for your test environment (though for unit tests its typically unnecessary and for higher levels adding a subscriber will suffice. For example, in Cucumber or its analogues:

    #features/env.rb
    Repository.configuration.add_default_listener EventMonitor.new

### Observers
Replay provides a default message router for observers of events. 

In your repository implementation, add :replay_router to the configuration's default subscribers:

    class Repository
      include Replay::Repository

      configure do |config|
        config.add_default_subscriber :replay_router
      end
    end

In your application or domain services:

    class MailService
      include Replay::Observer

      observe Model::EventHappened do |event|
        #handle the event 
      end
    end

It may be advantageous in some situations to create multiple routers:

    class InternalRouter
      include Replay::Router
    end

    class Repository
      include Replay::Repository

      configure do |config|
        config.add_default_subscriber InternalRouter
      end
    end

    class MailService
      include Replay::Observer
      router InternalRouter

      #observations...
    end

## Additional gems

[replay-rails](http://github.com/karmajunkie/replay-rails) provides a very basic ActiveRecord-based event store. Its a good template for building your own event store and light duties in an application in which aggregates don't receive hundreds or thousands of events. 


## TODO
* Implement snapshots for efficient load from repository
* Better documentation
* Build a demonstration app
