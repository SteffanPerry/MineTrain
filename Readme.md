# MineTrain
A lightweight and easy to use shard for running crystal in AWS Lambda

MineTrain was heavily influenced by the following projects:
  - https://github.com/spinscale/crystal-aws-lambda
  - https://github.com/lambci/crambda

## Installation
Add MineTrain to your crystal functions `shards.yml` file

```
dependencies:
  mine_train:
    github: SteffanPerry/MineTrain
    branch: master
```

## Usage
Create a method that optionally accepts the mine-train event and context types:

```
require "mine-train"

class CustomClass
  def self.perform(event : MineTrain::Lambda::Event, context :MineTrain::Lambda::Context)
    # Do work...
  end
end
```

In your entry file, require `mine-train` and pass a block with your method:

```
require "mine-train"
require "./custom_class.cr"

mine_train_run do |event, context|
  CustomClass.perform(event, context)
end
```

You can use use event values within the `mine_train_run` block to dynamically call specific jobs based on input. Additionally, methods do not need to accept event or context arguments if they are not required.

```
# custom_class.cr
require "mine-train"

class CustomClass
  def self.perform(event : MineTrain::Lambda::Event, context :MineTrain::Lambda::Context)
    # Do work...
  end

  def self.perform_two(event : MineTrain::Lambda::Event)
    # Do work...
  end

  def self.perform_three
    # Do work...
  end
end
```

```
# main.cr
require "mine-train"
require "./custom_class.cr"

mine_train_run do |event, context|
  case event.body["value"]
  when "perform"
    CustomClass.perform(event, context)
  when "perform_two"
    CustomClass.perform_two(event)
  when "perform_three"
    CustomClass.perform_three
  end
end
```

## MineTrain::Lambda::Event
The `MineTrain::Lambda::Event` type has two public methods:

### body
this is the JSON parsed value of the raw event.body

### raw
This is the raw event request from the lambda invocation

## MineTrain::Lambda::Context
The `MineTrain::Lambda::Context` type has the following public methods:

### function_name
The name of the lambda function

### function_version
The version of the lambda function

### memory_limit_in_mb
The configured memory for the lambda function

### log_group_name
The lambda functions log group

### log_stream_name
The log stream for the lambda function

### aws_request_id
The unique AWS request ID

### invoked_function_arn
The ARN of the invoked function

### deadline_ms
The remaining time in mills to complete the lambda function

### identity (optional)
The cognito invocation identity

### client_context (optional)
The client context of the lambda function

### get_remaining_time_in_millis
Method which returns the remaining time to complete the function
