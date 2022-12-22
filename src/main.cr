require "./lambda_runtime"
require "./event_handler"

lambda_event_loop do |event, context|
  ::EventHandler
    .new(event, context)
    .process!
end
