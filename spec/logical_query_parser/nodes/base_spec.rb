require 'spec_helper'
require 'logical_query_parser/nodes/base'

describe 'LogicalQueryParser::Base' do
  before do
    @parser = LogicalQueryParser.new
  end

  it 'parses one word' do
    result = @parser.parse("aa")
    expect(result).not_to be nil
  end

  it 'parses two words' do
    result = @parser.parse("aa bb")
    expect(result).not_to be nil
  end

  it 'parses negative operation (1)' do
    result = @parser.parse("-aa bb")
    expect(result).not_to be nil
  end

  it 'parses negative operation (2)' do
    result = @parser.parse("aa -bb")
    expect(result).not_to be nil
  end

  it 'parses quoted string' do
    result = @parser.parse('"aa bb"')
    expect(result).not_to be nil
  end

  it 'parses AND operation' do
    result = @parser.parse("aa AND bb")
    expect(result).not_to be nil
  end

  it 'parses AND operations' do
    result = @parser.parse("aa AND bb AND cc")
    expect(result).not_to be nil
  end

  it 'parses AND operation with parentheses' do
    result = @parser.parse("(aa AND bb)")
    expect(result).not_to be nil
  end

  it 'parses AND and OR operations (1)' do
    result = @parser.parse("(aa OR bb) AND cc")
    expect(result).not_to be nil
  end

  it 'parses AND and OR operations (2)' do
    result = @parser.parse("aa AND (bb OR cc)")
    expect(result).not_to be nil
  end

  it 'parses complex operations (1)' do
    result = @parser.parse("(aa OR bb) AND (cc OR dd)")
    expect(result).not_to be nil
  end

  it 'parses complex operations (2)' do
    result = @parser.parse('"aa bb" AND -"cc dd" AND (ee OR ff)')
    expect(result).not_to be nil
  end

  it 'returns nil if it cannot parse input string' do
    result = @parser.parse("a AND b (c AND d)")
    expect(result).to be nil
  end
end
