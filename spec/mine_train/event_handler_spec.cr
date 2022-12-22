require "../spec_helper.cr"

raw_event = begin
  response_data = File.open("./spec/fixtures/invocation_response/sample.json") { |file| file.gets_to_end }
  parsed_data = JSON.parse(response_data)
  headers = HTTP::Headers.new
  parsed_data["headers"].as_h.each do |k,v|
    headers[HTTP::Headers::Key.new(k)] = v.to_s
  end
  HTTP::Client::Response.new(200, parsed_data["body"].to_s, headers)
end

event = MineTrain::Lambda::Event.new(raw_event)
context = MineTrain::Lambda::Context.new(raw_event)

describe MineTrain::EventHandler do
  describe "initialize" do
    it "assignes event" do
      instance = EventHandler.new(event, context)
      instance.event.should eq(event)
    end
  end

  describe "#process!" do
    it "invokes mapped method" do
      instance = EventHandler.new(event, context)
      instance.process!
    end
  end
end