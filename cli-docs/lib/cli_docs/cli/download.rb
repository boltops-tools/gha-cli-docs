require "bundler"

class CliDocs::CLI
  class Download < Base
    def run
      repo_path = clone_repo
      bundle_install(repo_path)
    end

    def clone_repo
      repo = @options[:repo] || infer_repo_option
      @source_path = if File.exist?(repo)
        puts "Using existing repo at: #{repo}"
        repo # path to local folder with existing repo
      else
        check_repo_option!(repo)
        repo ||= current_folder.sub(/-docs$/, "")
        puts "Cloning #{repo} repo to build docs..."
        org = repo.split("/").first
        org_path = "/tmp/cli-docs/#{org}"
        repo_path = "/tmp/cli-docs/#{repo}"
        if File.exist?(repo_path)
          puts "Using existing repo: #{repo_path}"
          sh "cd #{repo_path} && git pull"
        else
          FileUtils.mkdir_p(org_path)
          puts "Cloning repo to: /tmp/cli-docs/#{repo}"
          Dir.chdir(org_path) do
            sh "git clone https://github.com/#{repo}"
          end
        end
        repo_path
      end
    end

    def bundle_install(repo_path)
      puts "Cd into repo and bundle install..."
      Dir.chdir(repo_path) do
        Bundler.with_unbundled_env do
          sh "bundle install"
        end
      end
    end

    def sh(command)
      puts "=> #{command}"
      system(command)
    end
  end
end
