
require "http/client"
require "./mine_train/*"

module MineTrain
  API_VERSION     = "2018-06-01"
  INVOCATION_URL  = "http://#{ENV["AWS_LAMBDA_RUNTIME_API"]}/#{API_VERSION}/runtime"

  def self.fetch_event : HTTP::Client::Response
    event = HTTP::Client.get("#{INVOCATION_URL}/invocation/next")
    raise "InvalidEvent" if event.nil?
    raise "unexpected response #{event.status_code}" unless event.status_code == 200

    event
  end
  
  def self.send_response(event : HTTP::Client::Response, result)
    request_id = event.headers["Lambda-Runtime-Aws-Request-Id"]
    HTTP::Client.post("#{INVOCATION_URL}/invocation/#{request_id}/response", body: result, headers: nil)
  end
  
  def self.send_error_response(event : HTTP::Client::Response, ex : Exception)
    request_id = event.headers["Lambda-Runtime-Aws-Request-Id"]
    HTTP::Client.post("#{INVOCATION_URL}/invocation/#{request_id}/error", body: ex.message, headers: nil)
  end
  
  def self.send_initialization_error_response(ex : Exception)
    data = {
      "errorMessage": ex.message,
      "errorType": ex.cause,
      "stackTrace": ex.backtrace
    }.to_s

    HTTP::Client.post("#{INVOCATION_URL}/init/error", body: data, headers: nil)
  end
end

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
