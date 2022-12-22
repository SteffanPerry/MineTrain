require "./mine_train/lambda_runtime"
require "./mine_train/event_handler"

lambda_event_loop do |event, context|
  MineTrain::EventHandler
    .new(event, context)
    .process!
end
