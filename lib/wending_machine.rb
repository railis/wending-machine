Dir[
  File.join(File.expand_path("..", __FILE__), File.basename(__FILE__, ".rb"), "/**/*.rb")
].each do |filepath|
  require filepath
end

module WendingMachine
end
