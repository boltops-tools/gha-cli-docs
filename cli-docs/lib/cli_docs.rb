$stdout.sync = true unless ENV["CLI_DOCS_STDOUT_SYNC"] == "0"

$:.unshift(File.expand_path(__dir__))

require "cli_docs/autoloader"
CliDocs::Autoloader.setup

require "active_support"
require "active_support/core_ext/object"
require "active_support/core_ext/string"
require "memoist"
require "rainbow/ext/string"

module CliDocs
  class Error < StandardError; end
end
