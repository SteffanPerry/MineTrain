module MineTrain
  class EventHandler
    @event : MineTrain::Lambda::Event
    @context : MineTrain::Lambda::Context

    def initialize(event, context)
      @event    = event
      @context  = context
    end

    def process!
      entry_map[entry_method].call(event, context)
    end

    def entry_method(event)
      ::MineTrain.entry_method(event)
    end

    def entry_map
      ::MineTrain.entry_method
    end

    def self.default_method(event, context)
      "Hello from MineTrain"
    end
  end
end
