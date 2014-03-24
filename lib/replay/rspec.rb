require 'replay/test'
Replay::Publisher::ClassMethods.module_exec do
  def self.extended(base)
    @@publishers ||= []
    @@publishers << base
    base.send(:include, Replay::EventExaminer)
  end

end

RSpec::Matchers.define :publish do |expected_event|
  match do |proc_or_obj|
    if proc_or_obj.respond_to? :call
      result = proc_or_obj.call
      result.published?(expected_event)
    else
      raise "You need to use the expect(&block) syntax for the now"
    end
  end
  chain :using do |publisher|
    @publisher = publisher
  end
end

