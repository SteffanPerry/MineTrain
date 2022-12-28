def mine_train_run
  while true
    begin
      fetched_event = MineTrain.fetch_event
      event         = MineTrain::Lambda::Event.new(fetched_event)
      context       = MineTrain::Lambda::Context.new(fetched_event)

      result = yield(event, context)

      MineTrain.send_response(fetched_event, result)
    rescue ex
      return if fetched_event.nil?

      MineTrain.send_error_response(fetched_event, ex)
    end
  end
rescue ex
  MineTrain.send_initialization_error_response(ex)
end
