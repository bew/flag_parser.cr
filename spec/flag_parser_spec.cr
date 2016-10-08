require "./spec_helper"

describe FlagParser do
  describe "#parse" do
    it "simple arg" do
      arg1 = false
      arg2 = false

      FlagParser.parse %w(arg1 arg2) do |parser|
        parser.on "arg1" do
          arg1 = true
        end
        parser.on "arg2" do
          arg2 = true
        end
      end

      arg1.should be_true
      arg2.should be_true
    end

    it "a rule" do
      value = nil
      expected_value = "mYValUe"

      FlagParser.parse ["--option", expected_value] do |parser|
        parser.add_rule "VALUE", FlagParser::Rule::ID
        parser.on "--option VALUE" do |(a_value)|
          value = a_value
        end
      end

      value.should eq(expected_value)
    end

    # TODO: split to a spec "is reusable with rules"
    it "multiple rules, multiple times" do
      parser = FlagParser.new

      parser.add_rule "OPTION", FlagParser::Rule::ID
      parser.add_rule "NUMBER", /^\d+$/

      option_holder = "no_option"
      number_holder = 0

      parser.on "-o OPTION NUMBER" do |(a_option, a_number)|
        nb = a_number.to_i
        option_holder = a_option
        number_holder = nb
      end

      parser.parse %w(-o first_option 1)
      option_holder.should eq("first_option")
      number_holder.should eq(1)

      parser.parse %w(-o second_option 42)
      option_holder.should eq("second_option")
      number_holder.should eq(42)
    end

    # TODO: rephrase ?
    it "ambiguous rules" do
      success = false

      FlagParser.parse %w(--option myvalue) do |parser|
        parser.on "--option something" do
        end

        parser.on "--option 42" do
        end

        parser.on "--option myvalue" do
          success = true
        end
      end

      success.should be_true
    end

    it "different flag format" do
      counter = 0

      FlagParser.parse %w(help -h --help) do |parse|
        parse.on "-h", "--help", "help" do
          counter += 1
        end
      end

      counter.should eq(3)
    end

    pending "raise on bad argument" do
      # TODO
    end

    pending "call specific callback on unknown arg" do
      # TODO
    end
  end
end
