require "bundler"

class CliDocs::CLI
  class Build < Download
    def run
      repo_path = clone_repo
      CliDocs::Markdown.new(@options.merge(repo_path: repo_path)).build
    end
  end
end
