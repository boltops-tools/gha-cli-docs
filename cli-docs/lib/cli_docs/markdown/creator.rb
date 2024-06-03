class CliDocs::Markdown
  class Creator
    def self.create_all(options = {})
      clean unless options[:parent_command_name]
      new(options).create_all
    end

    def self.clean
      FileUtils.rm_rf("_reference")
      FileUtils.rm_f("reference.md")
    end

    # cli_class is top-level CLI class.
    def initialize(options = {})
      @cli_class = options[:cli_class]
      @cli_name = options[:cli_name]
      @parent_command_name = options[:parent_command_name]
    end

    def create_all
      create_index unless @parent_command_name

      commands = @cli_class.commands.reject { |command_name, command| command.hidden? }
      commands.keys.each do |command_name|
        page = Page.new(
          cli_class: @cli_class,
          cli_name: @cli_name,
          command_name: command_name,
          parent_command_name: @parent_command_name
        )

        if subcommand?(command_name)
          subcommand_class = subcommand_class(command_name)
          parent_command_name = command_name

          puts "Creating subcommands pages for #{parent_command_name}..."
          Creator.create_all(
            cli_class: subcommand_class,
            cli_name: @cli_name,
            parent_command_name: parent_command_name
          )
        else
          create_page(page)
        end
      end
    end

    def create_page(page)
      puts "Creating #{page.path}..."
      FileUtils.mkdir_p(File.dirname(page.path))
      IO.write(page.path, page.doc)
    end

    def create_index
      create_include_reference
      index = Index.new(@cli_class, @cli_name)
      FileUtils.mkdir_p(File.dirname(index.path))
      puts "Creating #{index.path}"
      IO.write(index.path, index.doc)
    end

    def create_include_reference
      path = "_includes/reference.md"
      FileUtils.mkdir_p(File.dirname(path))
      IO.write(path, "Generic tool description. Please edit #{path} with a description.") unless File.exist?(path)
    end

    def subcommand?(command_name)
      @cli_class.subcommands.include?(command_name)
    end

    def subcommand_class(command_name)
      @cli_class.subcommand_classes[command_name]
    end
  end
end
