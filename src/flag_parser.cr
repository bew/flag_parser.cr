class FlagParser
  def self.parse(args)
    parser = FlagParser.new
    yield parser
    parser.parse args
    parser
  end

  def initialize
    @banner = [] of String
    @handlers = [] of FlagParser::Flag
    @rules = {} of String => Regex
  end

  def banner
    @banner
  end

  def banner=(string)
    @banner = [string]
  end

  def to_s
    result = ""
    @banner.each do |line|
      result += line
    end
    result
  end

  def help_group(group)
    # TODO
    nil
  end

  def add_rule(rule_name, rule : Regex)
    @rules[rule_name] = rule
  end

  def add_rule(rule_name, rule : String)
    if @rules[rule]?
      @rules[rule_name] = @rules[rule]
    else
      raise "Unknown rule name '#{rule}'"
    end
  end

  def branch_on(*flags, parser subparser, doc description = nil)
    flag_handlers = on_impl(*flags, doc: description) do |_, args|
      subparser.parse args
    end
  end

  def branch_on(*flags, parser subparser, doc description = nil, &block : Flag::Callback)
    flag_handlers = on_impl(*flags, doc: description, &block)
  end

  # type spec needed ?
  def on(*flags, doc description = nil, &block : Flag::Callback)
    on_impl(*flags, doc: description, &block)
    return #nil
  end

  protected def on_impl(*flags, doc description = nil, &block : Flag::Callback)
    flags.each do |flag|
      # split spaces
      #
      # not special arg
      # -> add to list
      #
      # special arg (regex)
      # -> process & add to list

      flag_parts = flag.split /\s+/

      # TODO: rename this
      flag_handler = Flag.new &block

      flag_parts.each do |flag_part|
        if @rules[flag_part]?
          # There is a regex rule for this arg part
          flag_handler.parts << @rules[flag_part]
        else
          # This arg part is just raw string
          flag_handler.parts << flag_part
        end
      end

      if flag_handler.parts.size > 0
        @handlers << flag_handler
      end
    end
  end

  def parse(args)
    while args.size > 0
      match = false

      @handlers.each do |handler|
        if handler.match? args
          match = true
          args.delete_at 0, handler.size
          # FIXME: we give the args for when the callback will make a sub parser
          # the subparser thing must have rework
          handler.execute args
          break
        end
      end

      if !match
        puts "~ NO MATCH FOR PENDING ARGS: #{args.to_s}"
        return false
      end
    end

    return true
  end
end

class FlagSubParser < FlagParser
  getter upvalues

  def initialize(@upvalues = {} of Symbol => String)
    super
  end

  def parse(args, @upvalues)
    super args
  end
end

# TODO: rename, this is not 'arg' but 'Flag'
struct FlagParser::Flag
  alias Callback = Array(String), Array(String) ->

  getter parts : Array(String | Regex)

  def initialize(&@callback : Callback)
    @parts = [] of String | Regex
    @last_dynamic_matches = [] of String
  end

  def size
    @parts.size
  end

  def execute(args)
    @callback.call @last_dynamic_matches, args
  end

  def match?(args)
    @last_dynamic_matches.clear
    return false if args.size < @parts.size

    args_it = args.each

    @parts.each do |arg_matcher|
      arg = args_it.next
      if arg.is_a?(Iterator::Stop)
        return false
      end

      case arg_matcher
      when Regex
        if !arg_matcher.match arg
          return false
        else
          # save the value matching the regex
          @last_dynamic_matches << arg
        end
      when String
        if arg_matcher != arg
          return false
        end
      end
    end

    return true
  end
end

class FlagParser::Rule
  ID  = /^[\w_][\w_\d]*$/
  NUM = /^\d+$/
  ANY = /.*/im
  # URL = nil

end
