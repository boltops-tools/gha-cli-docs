require "active_support/core_ext/string"

class CliDocs::Markdown
  class Index
    def initialize(cli_class, cli_name, parent_command_name = nil)
      @cli_class = cli_class
      @cli_name = cli_name
      @parent_command_name = parent_command_name
    end

    def doc
      <<~EOL
        ---
        title: CLI Reference
        ---
        {% include reference.md %}

        #{command_list}
      EOL
    end

    def command_list
      pages = build_pages
      list = pages.map { |page| markdown_link(page) }
      list.join("\n")
    end

    def build_pages
      pages = []
      commands = @cli_class.commands.reject { |command_name, command| command.hidden? }
      commands.keys.sort.each do |command_name|
        next if command_name == "help"
        page = Page.new(
          cli_class: @cli_class,
          cli_name: @cli_name,
          command_name: command_name,
          parent_command_name: @parent_command_name
        )

        if subcommand?(command_name)
          subclass = subcommand_class(command_name)
          parent_name = subclass.to_s.demodulize.underscore
          index = Index.new(subclass, @cli_name, parent_name)
          sub_pages = index.build_pages
          links = sub_pages.map { |page| markdown_link(page) }
          pages += sub_pages
        else
          pages << page
        end
      end
      pages.sort_by { |page| page.full_command_name }
    end

    def subcommand_class(command_name)
      @cli_class.subcommand_classes[command_name]
    end

    def markdown_link(page)
      "* [#{page.full_command_name}]({% link #{page.path} %})"
    end

    def subcommand?(command_name)
      @cli_class.subcommands.include?(command_name)
    end

    def path
      "reference.md"
    end
  end
end
