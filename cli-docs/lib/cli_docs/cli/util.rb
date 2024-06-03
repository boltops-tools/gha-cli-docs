class CliDocs::CLI
  module Util
    def sh(command, options = {})
      quiet = options[:quiet]
      on_fail = options[:on_fail] || :raise

      puts "=> #{command}" unless quiet
      system(command)
      success = $?.success?

      case on_fail
      when :raise
        raise "Command failed: #{command}\n#{caller(1..1).first}" unless success
      when :exit
        unless success
          if quiet
            abort("Command failed: #{command}\n")
          else
            abort("Command failed: #{command}\n#{caller.join("\n")}")
          end
        end
      end

      success
    end

    def capture(command)
      out = `#{command}`.strip
      raise "Command failed: #{command}\n#{caller(1..1).first}" unless $?.success?
      out
    end
  end
end
