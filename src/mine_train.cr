
# require "./mine_train/event_handler"
require "http/client"
require "./mine_train/lambda/event.cr"
require "./mine_train/lambda/context.cr"
require "./mine_train/lambda_runtime.cr"

module MineTrain
  API_VERSION     = "2018-06-01"
  INVOCATION_URL  = "http://#{ENV["AWS_LAMBDA_RUNTIME_API"]}/#{API_VERSION}/runtime"

  # class_getter configuration = MineTrain::Configuration.new

  # Configure Minetrain
  #
  # ```
  # MineTrain.configure do |config|
  #   config.entry_map = { "default":  -> { CustomClass.perform }, }
  #   config.entry_method = -> (event, context){ "default" }
  # end
  # ```
  #def self.configure(&block) : Nil
  #  yield configuration
  #end

  #def self.entry_map
  #  configuration.entry_map
  #end

  #def self.entry_method(event)
  #  configuration.entry_method
  #end

  #def self.default_method(event, context)
  #  "Hello from MineTrain"
  #end

  #class Configuration
  #  property entry_method = -> (event) { "default" }

  #  property entry_map = {
  #    "default": -> (event, context) { MineTrain.default_method(event, context) }
  #  }
  #end

  def self.fetch_event : HTTP::Client::Response
    event = HTTP::Client.get("#{INVOCATION_URL}/invocation/next")
    raise "InvalidEvent" if event.nil?
    raise "unexpected response #{event.status_code}" unless event.status_code == 200
  
    event
  end
  
  def self.process!(event : MineTrain::Lambda::Event, context : MineTrain::Lambda::Context)
    MineTrain::EventHandler
      .new(event, context)
      .process!
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