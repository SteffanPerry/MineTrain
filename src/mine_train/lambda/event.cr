require "json"

module MineTrain
  module Lambda
    class Event
      @event : HTTP::Client::Response

      def initialize(@event)
      end

      def body : JSON::Any
        JSON.parse(@event.body)
      end

      def raw : HTTP::Client::Response
        @event
      end
    end
  end
end
