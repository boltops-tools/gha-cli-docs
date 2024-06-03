module CliDocs
  class Markdown < CliDocs::CLI::Base
    def initialize(options = {})
      super
      @repo_path = options[:repo_path]
    end

    def build
      puts "Building reference docs for: #{@repo_path}"
      cli_name = File.basename(@repo_path)  # tool
      cli_class = infer_cli_class(cli_name) # Tool::CLI
      Creator.create_all(cli_class: cli_class, cli_name: cli_name)
    end

    def infer_cli_class(cli_name)
      ENV["BUNDLE_GEMFILE"] = "#{@repo_path}/Gemfile"
      require "bundler/setup"
      Bundler.with_unbundled_env do
        Dir.chdir(@repo_path) do
          require cli_name
          "#{cli_name.camelize}::CLI".constantize
        end
      end
    end
  end
end
