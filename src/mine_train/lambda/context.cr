require "json"

module MineTrain
  module Lambda
    class Context
      @event : HTTP::Client::Response

      getter function_name : String
      getter function_version : String
      getter memory_limit_in_mb : UInt32
      getter log_group_name : String
      getter log_stream_name : String
      getter aws_request_id : String
      getter invoked_function_arn : String
      getter deadline_ms : Int64
      getter identity : JSON::Any | Nil
      getter client_context : JSON::Any | Nil

      def initialize(@event)
        @function_name = ENV["AWS_LAMBDA_RUNTIME_API"]
        @function_version = ENV["AWS_LAMBDA_FUNCTION_VERSION"]
        @memory_limit_in_mb = UInt32.new(ENV["AWS_LAMBDA_FUNCTION_MEMORY_SIZE"])
        @log_group_name = ENV["AWS_LAMBDA_LOG_GROUP_NAME"]
        @log_stream_name = ENV["AWS_LAMBDA_LOG_STREAM_NAME"]
        @aws_request_id = @event.headers["Lambda-Runtime-Aws-Request-Id"]
        @invoked_function_arn = @event.headers["Lambda-Runtime-Invoked-Function-Arn"]
        @deadline_ms = context_deadline
        @identity = identity
        @client_context = client_context
      end

      def get_remaining_time_in_millis
        @deadline_ms - Time.now.to_unix_ms
      end

      private def identity
        data = @event.headers["Lambda-Runtime-Cognito-Identity"]? || ""
        return if data.to_s.blank?

        JSON.parse(data)
      end

      private def client_context
        ctx = @event.headers["Lambda-Runtime-Client-Context"]? || ""
        return if ctx.to_s.blank?

        JSON.parse(ctx)
      end

      private def context_deadline
        deadline = @event.headers["Lambda-Runtime-Deadline-Ms"]? || 0

        Int64.new(deadline)
      end
    end
  end
end
