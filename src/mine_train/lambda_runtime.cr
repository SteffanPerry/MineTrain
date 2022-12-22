require "http/client"
require "./lambda/event.cr"
require "./lambda/context.cr"

API_VERSION     = "2018-06-01"
INVOCATION_URL  = "http://#{ENV["AWS_LAMBDA_RUNTIME_API"]}/#{API_VERSION}/runtime"

def mine_train_run
  while true
    begin
      fetched_event = fetch_event
      event         = MineTrain::Lambda::Event.new(fetched_event)
      context       = MineTrain::Lambda::Context.new(fetched_event)
      
      result = yield(event, context)

      send_response(fetched_event, result)
    rescue ex
      return if fetched_event.nil?

      send_error_response(fetched_event, ex)
    end
  end
rescue ex
  send_initialization_error_response(ex)
end
