# flag_parser

Yet another command line flag parser library :)

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  flag_parser:
    github: Bew78LesellB/flag_parser.cr
```


## Usage


```crystal
require "flag_parser"

value = 0

args = %w(--option 42)

FlagParser.parse args do |parser|
  parser.add_rule "VALUE", FlagParser::Rule::NUM

  parser.on "-o VALUE", "--option VALUE", doc: "Set option value" do |(a_value)|
    value = a_value.to_i
  end
end

puts value # => 42
```


TODO: Write more usage instructions here

## Contributing

1. Fork it ( https://github.com/Bew78LesellB/flag_parser.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Bew78LesellB](https://github.com/Bew78LesellB) Benoit de Chezelles - creator, maintainer
