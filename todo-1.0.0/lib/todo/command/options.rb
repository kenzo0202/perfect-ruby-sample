require 'optparse'

module Todo
  class Command
    module Options
      def self.parse!(argv)
        options = {}

        #サブコマンドなどのOptionsParserを定義
        sub_command_parsers = create_sub_command_parsers(options)
        command_parser = create_command_parser
        begin
          command_parser.order!(argv)

          options[:command] = argv.shift

          sub_command_parsers[options[:command]].parse! argv

          #updateとdeleteの場合はidを取得する
          if %w(update delete).include?(options[:command])
            raise ArgumentError, "#{options[:command]} id not found." if argv.empty?
            options[:id] = Integer(argv.first)
          end

        rescue OptionParser::MissingArgument, OptionParser::InvalidOption, ArgumentError => e
          abort e.message
        end
        options
      end

      class << self
        def create_sub_command_parsers(options)
          #サブコマンドの処理をする際に、未定義のkeyを指定されたら例外を発生させる
          sub_command_parsers = Hash.new do |k,v|
            raise ArgumentError, " #{v} is not todo sub command "
          end

          sub_command_parsers['create'] = OptionParser.new do |opt|
            opt.banner = 'Usage: create <args>'
            opt.on('-n VAL','--name=VAL', 'task name') {|v| options[:name] = v}
            opt.on('-c VAL','--content=VAL', 'task content') {|v| options[:content] = v}
            opt.on_tail('-h', '--help', 'Show this message'){|v| help_sub_command(opt)}
          end

          sub_command_parsers['list'] = OptionParser.new do |opt|
            opt.banner = 'Usage: list <args>'
            opt.on('-s VAL','--status=VAL', 'list status') {|v| options[:status] = v}
            opt.on_tail('-h', '--help', 'Show this message'){|v| help_sub_command(opt)}
          end

          sub_command_parsers['update'] = OptionParser.new do |opt|
            opt.banner = 'Usage: update id <args>'
            opt.on('-n VAL','--name=VAL', 'update name') {|v| options[:name] = v}
            opt.on('-c VAL','--content=VAL', 'update content') {|v| options[:content] = v}
            opt.on('-s VAL','--status=VAL', 'update status') {|v| options[:status] = v}
            opt.on_tail('-h', '--help', 'Show this message'){|v| help_sub_command(opt)}
          end

          sub_command_parsers['delete'] = OptionParser.new do |opt|
            opt.banner = 'Usage: delete id'
            opt.on_tail('-h', '--help', 'Show this message'){|v| help_sub_command(opt)}
          end

          sub_command_parsers
        end

        def help_sub_command(opt)
          puts opt.help
          exit
        end


        def create_command_parser
          OptionParser.new do |opt|
            sub_command_help = [
                {name: 'create -n name -c content', summary: 'タスクを作成する'},
                {name: 'update id -n name -c content -s status', summary: 'タスクを削除する'},
                {name: 'list -s status', summary: 'タスクの一覧を見る'},
                {name: 'delete id', summary: 'タスクを削除する'},
            ]

            opt.banner = "Usage: #{opt.program_name} [-h|--help] [-v|--version] <command> [<args>]"
            opt.separator  ""
            opt.separator  "#{opt.program_name} Available Commands"
            sub_command_help.each do |command|
              opt.separator  [opt.summary_indent, command[:name].ljust(40), command[:summary]].join(' ')
            end

            opt.on_head('-h','--help', 'Show this message') do |v|
              puts opt.help
              exit
            end

            opt.on_head('-v','--version', 'Show program version') do |v|
              opt.version = Todo::VERSION
              puts opt.ver
              exit
            end
          end
        end
      end

      private_class_method :create_sub_command_parsers, :create_command_parser, :help_sub_command

    end
  end
end
