class CliDocs::CLI
  class Base
    include Util

    def initialize(options = {})
      @options = options
    end

    # Example return value:
    #   user/repo
    def infer_repo_option
      if ENV["GITHUB_REPOSITORY"]
        # org/tool-docs
        ENV["GITHUB_REPOSITORY"].sub(/-docs$/, "")
      else
        repo_from_dot_git.sub(/-docs$/, "")
      end
    end

    # Example return value:
    #   user/repo-docs
    def repo_from_dot_git
      return unless File.exist?(".git/config")
      # get repo info from .git/config
      out = capture "git config --get remote.origin.url" # IE: git@github.com:user/repo-docs.git
      if out.include?("fatal: not in a git directory")
        puts "ERROR: Not in a git directory. Please specify the repo option.".color(:red)
        abort "Example: user/repo"
      end

      if out.include?("https://")
        URI.parse(out).path.sub(/^\//, "").sub(/\.git$/, "")
      else
        out.split(":").last.sub(/\.git$/, "")
      end
    end

    def check_repo_option!(repo)
      unless repo.include?("/") && repo.split("/").size == 2
        puts "ERROR: repo option must be in the form of org/repo".color(:red)
        puts "Current repo value is: #{repo}"
        abort "Example: user/repo"
      end
    end
  end
end
