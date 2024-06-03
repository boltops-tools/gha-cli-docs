module CliDocs
  class CLI < Command
    desc "download", "download docs repo"
    option :repo, desc: "CLI repo, when not set its inferred"
    def download
      Download.new(options).run
    end

    desc "build", "Build docs"
    option :repo, desc: "CLI repo, when not set its inferred"
    def build
      Build.new(options).run
    end

    desc "version", "prints version"
    def version
      puts VERSION
    end
  end
end
