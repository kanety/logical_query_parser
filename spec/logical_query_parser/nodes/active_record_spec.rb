require 'spec_helper'
require 'active_record_helper'
require 'logical_query_parser/nodes/active_record'

describe 'LogicalQueryParser::ActiveRecord' do
  before do
    @parser = LogicalQueryParser.new
    @opts = { model: Doc, columns: %w(title body) }
  end

  it 'parses one word' do
    result = @parser.parse("aa").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses two words' do
    result = @parser.parse("aa bb").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses negative operation (1)' do
    result = @parser.parse("-aa bb").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses negative operation (2)' do
    result = @parser.parse("aa -bb").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses quoted string' do
    result = @parser.parse('"aa bb"').to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses AND operation' do
    result = @parser.parse("aa AND bb").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses AND operations' do
    result = @parser.parse("aa AND bb AND cc").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses AND operation with parentheses' do
    result = @parser.parse("(aa AND bb)").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses AND and OR operations (1)' do
    result = @parser.parse("(aa OR bb) AND cc").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses AND and OR operations (2)' do
    result = @parser.parse("aa AND (bb OR cc)").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses complex operations (1)' do
    result = @parser.parse("(aa OR bb) AND (cc OR dd)").to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end

  it 'parses complex operations (2)' do
    result = @parser.parse('"aa bb" AND -"cc dd" AND (ee OR ff)').to_sql(@opts)
    expect(Doc.where(result).to_a).not_to be nil
  end
end
