require 'replay/test'

RSpec::Matchers.define :publish do |expected_event|
  match do |proc_or_obj|
    if proc_or_obj.respond_to? :call
      result = proc_or_obj.call
      result.published?(expected_event, @fuzzy)
    else
      proc_or_obj.published?(expected_event, @fuzzy)
    end
  end
  chain :fuzzy do 
    @fuzzy = true
  end
end

