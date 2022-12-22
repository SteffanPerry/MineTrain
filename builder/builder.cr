require "yaml"
require "compress/zip"
require "io"

BUILDER_PATH = "/lambda-builder"

def exec(command)
  io = IO::Memory.new
  res = Process.run(command, shell: true, output: io)
  output = io.to_s
  puts io.to_s if output.size > 0
  raise "command execution error" unless res.success?
  res.success?
end

puts "Start building binaries..."

system("shards build --static --release")
shard_yml = File.open("shard.yml") do |file|
  YAML.parse(file)
end

shard_yml["targets"].as_h.each do |bin, main_path|
  bin_path = "src/."

  system "mkdir build-tmp && mkdir -p lambda"
  system "cp -a #{bin_path} build-tmp/."
  system "cp builder/bootstrap build-tmp/."
  system "cd build-tmp && zip -r #{bin}.zip . && cd --"
  system "cp -f build-tmp/#{bin}.zip lambda/."
  system "rm -rf build-tmp"
rescue ex
  puts ex.message 
end