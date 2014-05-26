require 'replay/test'

RSpec::Matchers.define :publish do |expected_event|
  match do |proc_or_obj|
    if proc_or_obj.respond_to? :call
      @result = proc_or_obj.call
      @result.published?(expected_event, @fuzzy)
    else
      proc_or_obj.published?(expected_event, @fuzzy)
    end
  end

  chain :fuzzy do 
    @fuzzy = true
  end

  def failure_message(expected_event, actual, should = true)
    actual = @result if actual.is_a? Proc

    str = "expected that #{domain_obj_interpretation(actual)} would#{should ? ' ': ' not'} generate #{@fuzzy ? 'an event like' : 'the event'} #{event_interpretation(expected_event)}"
    similar = actual.similar_events(expected_event)
    if similar.empty?
      str += "\nNo similar events found."
    else
      str += "\nThe following events matched type, but not attributes:\n#{similar.map{|s| event_interpretation(s)+"\n"}.join("\t\t")}"
    end
  end
  failure_message_for_should_not do |actual|
    failure_message(expected_event, actual, false)
  end

  failure_message_for_should do |actual|
    failure_message(expected_event, actual )
  end

  def domain_obj_interpretation(obj)
    if obj.respond_to?(:call) && obj.kind_of?(Proc)
      "block"
    else
      obj.class.to_s
    end

  end

  def event_interpretation(event)
    "#{event.type} [#{event.attributes.reject{|k,v| v.nil?}.keys.map{|k| "#{k.to_s} = #{event.attributes[k]}"}.join(", ")}]"
  end

end

