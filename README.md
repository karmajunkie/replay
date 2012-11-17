# Replay

Event-sourced data uses Plain Old Ruby Objects (POROs) to model your data and exclusively uses events to mutate state on those objects.

See Also:

* [http://martinfowler.com/eaaDev/EventSourcing.html](http://martinfowler.com/eaaDev/EventSourcing.html)
* [http://codebetter.com/gregyoung/2010/02/20/why-use-event-sourcing/](http://codebetter.com/gregyoung/2010/02/20/why-use-event-sourcing/)
* [http://www.confreaks.com/videos/869-railsconf2012-use-the-source-luke-high-fidelity-history-with-event-sourced-data](http://www.confreaks.com/videos/869-railsconf2012-use-the-source-luke-high-fidelity-history-with-event-sourced-data) 

## Installation

Add this line to your application's Gemfile:

    gem 'replay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install replay

## Examples

### replayable domain model

```
class Domain::Model 
  include Replay::Domain

  def twitter_update
    #do stuff
    signal_event "twitter_updated", status
    self.save
  end

  apply "twitter_updated" do |status|
    model.twitter_status = status
  end
  
end
```

### usage

```
model = Model.find(params[:model_id])
model.twitter_update
```

### listener

```
class TweetReport
  include Replay::Projector
  listen :twitter_updated do |model_id, status|
    #update read model/report/whatever...
  end
end
```
