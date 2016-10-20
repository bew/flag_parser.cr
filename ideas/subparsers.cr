require "../src/flag_parser"

# ex:





# FIXME: how to pass config options altered by parser, to the actual parser ?

# NOTE-IDEA: pass the config when parsing:
# parser.parse args, my_config
#
# and access it in all rules :
# ```
# parser.on "--verbose" do |_, config|
#   config.verbose = true
# end
# ```
# BUT THEN, what is the case of using upvalues ? (maybe there is one !)
#
# and what would be the type of 'config' ?
# => FlagParser could be a template on the config type
# => p = `FlagParser(MyConfig).new`

# NOTE-IDEA: The second argument of all callback could be an object
# describing the parsing_state, and contain :
# - the pending args to parse
# - the state of the current config for this parser (see IDEA above)
# ```
# parser.on "--verbose" do |_, state|
#   state.config.verbose = true
# end
# ```
