class EventHandler
  @event : Lambda::Event
  @context : Lambda::Context

  def initialize(event, context)
    @event    = event
    @context  = context
  end

  def process!
    entry_map[entry_method].call
  end

  def entry_method
    "default"
  end

  def entry_map
    { 
      "default":  -> { EventHandler.default_method }
    }
  end

  def self.default_method
    "Hello from MineTrain"
  end
end
