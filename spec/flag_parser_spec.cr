require "./spec_helper"

describe FlagParser do
  describe "#parse" do
    it "simple arg" do
      arg1 = false
      arg2 = false

      parser = FlagParser.new.tap do |parser|
        parser.on "arg1" do
          arg1 = true
        end
        parser.on "arg2" do
          arg2 = true
        end
      end

      parser.parse %w(arg1 arg2)
      arg1.should be_true
      arg2.should be_true
    end

    it "a rule" do
      value = nil
      expected_value = "mYValUe"

      parser = FlagParser.new.tap do |parser|
        parser.add_rule "VALUE", FlagParser::Rule::ID
        parser.on "--option VALUE" do |(a_value)|
          value = a_value
        end
      end

      parser.parse ["--option", expected_value]
      value.should eq(expected_value)
    end

    # TODO: split to a spec "is reusable with rules"
    it "multiple rules, multiple times" do
      option_holder = "no_option"
      number_holder = 0

      parser = FlagParser.new.tap do |parser|

        parser.add_rule "OPTION", FlagParser::Rule::ID
        parser.add_rule "NUMBER", /^\d+$/

        parser.on "-o OPTION NUMBER" do |(a_option, a_number)|
          nb = a_number.to_i
          option_holder = a_option
          number_holder = nb
        end
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

      parser = FlagParser.new.tap do |parser|
        parser.on "--option something" do
        end

        parser.on "--option 42" do
        end

        parser.on "--option myvalue" do
          success = true
        end
      end

      parser.parse %w(--option myvalue)
      success.should be_true
    end

    it "different flag format" do
      counter = 0

      parser = FlagParser.new.tap do |parser|
        parser.on "-h", "--help", "help" do
          counter += 1
        end
      end

      parser.parse %w(help -h --help)
      counter.should eq(3)
    end

    pending "raise on bad argument" do
      # TODO
    end

    pending "call specific callback on unknown arg" do
      # TODO
    end
  end

  describe "#branch_on" do
    # init sub parsers

    suboption = false
    subparser_simple = FlagParser.new.tap do |parser|
      parser.on "-so" do
        suboption = true
      end
    end

    subname = ""
    subparser_upvalue = FlagSubParser.new.tap do |parser|
      parser.on "-so" do
        subname = "wtf"
      end

      parser.add_rule "RULE", FlagParser::Rule::ID

      parser.on "-sn" do
        subname = parser.upvalues[:name]
      end
    end

    Spec.before_each do
      suboption = false
      subname = ""
    end

    it "automatic simple flag" do
      parser = FlagParser.new
      parser.branch_on "sub", parser: subparser_simple

      parser.parse %w(sub -so)
      suboption.should be_true
    end

    it "manual flag with rule" do
      parser = FlagParser.new
      parser.add_rule "NAME", FlagParser::Rule::ID

      parser.branch_on "sub NAME", parser: subparser_upvalue do |(name), args|
        subparser_upvalue.parse args, upvalues: {:name => name}
      end

      parser.parse %w(sub my_name -sn)
      subname.should eq("my_name")
    end
  end
end
