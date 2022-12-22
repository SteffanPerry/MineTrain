require "spec"
require "dotenv"

Dotenv.load(path: ".env.test")

require "../src/mine_train.cr"

def create_test_object(name)
  project = MyProject.new(option: false)
  object = project.create_object(name)
  object
end
