class CliDocs::Markdown
  class Page
    attr_reader :cli_name, :command_name
    def initialize(cli_class:, cli_name:, command_name:, parent_command_name: nil)
      @cli_class = cli_class  # IE: Tool::Commands::Main
      @cli_name = cli_name    # IE: tool
      @command_name = command_name # IE: generate
      @parent_command_name = parent_command_name # IE: command
      @command = @cli_class.commands[@command_name]
    end

    def full_command_name
      command = [@parent_command_name, @command_name].compact.join(":")
      [@cli_name, command].compact.join(" ")
    end

    def usage
      banner = @cli_class.send(:banner, @command) # banner is protected method
      invoking_command = File.basename($0) # could be rspec, etc
      banner.sub(invoking_command, cli_name)
    end

    def description
      @command.description
    end

    def options
      shell = Shell.new
      @cli_class.send(:class_options_help, shell, nil => @command.options.values)
      text = shell.stdout.string
      return "" if text.empty? # there are no options

      lines = text.split("\n")[1..] # remove first line with "Options: "
      lines.map! do |line|
        # remove 2 leading spaces
        line.sub(/^  /, "")
      end
      lines.join("\n")
    end

    # Use command's long description as many description
    def long_description
      text = @command.long_description
      return "" if text.nil? # empty description

      lines = text.split("\n")
      lines.map do |line|
        # In the CLI help, we use 2 spaces to designate commands
        # In Markdown we need 4 spaces.
        line.sub(/^  \b/, "    ")
      end.join("\n")
    end

    def path
      full_name = if @parent_command_name
        "#{cli_name}-#{@parent_command_name}-#{@command_name}"
      else
        "#{cli_name}-#{@command_name}"
      end
      "_reference/#{full_name}.md"
    end

    def subcommand?
      @cli_class.subcommands.include?(@command_name)
    end

    def subcommand_class
      @cli_class.subcommand_classes[@command_name]
    end

    # Note:
    # printable_commands are in the form:
    #  [
    #    [command_form,command_comment],
    #    [command_form,command_comment],
    #  ]
    #
    # It is useful to grab the command form printable_commands as it shows
    # the proper form.
    def subcommand_list
      return "" unless subcommand?

      invoking_command = File.basename($0) # could be rspec, etc
      command_list = subcommand_class.printable_commands
        .sort_by { |a| a[0] }
        .map { |a|
                       a[0].sub!(invoking_command, cli_name)
                       a
                     } # replace with proper comand
        .reject { |a| a[0].include?("help [COMMAND]") } # filter out help

      # dress up with markdown
      text = command_list.map do |a|
        command, comment = a[0], a[1].sub(/^# /, "")
        subcommand_name = command.split(" ")[2]
        full_command_path = "#{cli_name}-#{@command_name}-#{subcommand_name}"
        full_command_name = "#{cli_name} #{@command_name} #{subcommand_name}"
        link = "_reference/#{full_command_path}.md"

        # "* [#{command}]({% link #{link} %})"
        # Example: [tool command]({% link _reference/tool-command.md %})
        "* [#{full_command_name}]({% link #{link} %}) - #{comment}"
      end.join("\n")

      <<~EOL
        ## Subcommands

        #{text}
      EOL
    end

    def doc
      <<~EOL
        #{front_matter}
        #{usage_markdown}
        #{long_desc_markdown}
        #{subcommand_list}
        #{options_markdown}
      EOL
    end

    def front_matter
      command = [@parent_command_name, @command_name].compact.join(":")
      title = [cli_name, command].compact.join(" ")
      <<~EOL
        ---
        title: #{title}
        reference: true
        ---
      EOL
    end

    def usage_markdown
      <<~EOL
        ## Usage

            #{usage}
      EOL
    end

    def desc_markdown
      <<~EOL
        ## Description

        #{description}
      EOL
    end

    # If the Thor long_description is empty then use the description.
    def long_desc_markdown
      return desc_markdown if long_description.empty?

      <<~EOL
        ## Description

        #{description}

        #{long_description}
      EOL
    end

    # handles blank options
    def options_markdown
      return "" if options.empty?

      <<~EOL
        ## Options

        ```
        #{options}
        ```
      EOL
    end
  end
end
