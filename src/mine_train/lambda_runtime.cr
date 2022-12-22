require "http/client"
require "./lambda/event.cr"
require "./lambda/context.cr"

API_VERSION     = "2018-06-01"
INVOCATION_URL  = "http://#{ENV["AWS_LAMBDA_RUNTIME_API"]}/#{API_VERSION}/runtime"

def lambda_event_loop
  while true
    begin
      event           = fetch_event
      lambda_event    = MineTrain::Lambda::Event.new(event)
      lambda_context  = MineTrain::Lambda::Context.new(event)

      result  = yield(lambda_event, lambda_context)

      send_response(event, result)
    rescue ex
      return if event.nil?

      send_error_response(event, ex)
    end
  end
rescue ex
  send_initialization_error_response(ex)
end

private def fetch_event : HTTP::Client::Response
  event = HTTP::Client.get("#{INVOCATION_URL}/invocation/next")
  raise "InvalidEvent" if event.nil?
  raise "unexpected response #{event.status_code}" unless event.status_code == 200

  event
end

private def send_response(event : HTTP::Client::Response, result)
  request_id = event.headers["Lambda-Runtime-Aws-Request-Id"]
  HTTP::Client.post("#{INVOCATION_URL}/invocation/#{request_id}/response", body: result, headers: nil)
end

private def send_error_response(event : HTTP::Client::Response, ex : Exception)
  request_id = event.headers["Lambda-Runtime-Aws-Request-Id"]
  HTTP::Client.post("#{INVOCATION_URL}/invocation/#{request_id}/error", body: ex.message, headers: nil)
end

private def send_initialization_error_response(ex : Exception)
  data = {
    "errorMessage": ex.message,
    "errorType": ex.cause,
    "stackTrace": ex.backtrace
  }.to_s

  HTTP::Client.post("#{INVOCATION_URL}/init/error", body: data, headers: nil)
end
