require 'spec_helper'
require 'logical_query_parser/nodes/base'

describe 'LogicalQueryParser::Base' do
  before do
    @parser = LogicalQueryParser.new
  end

  it 'parses one word' do
    result = @parser.parse("aa")
    expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
  end

  it 'parses two words' do
    result = @parser.parse("aa bb")
    expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
  end

  it 'parses negative operation (1)' do
    result = @parser.parse("-aa bb")
    expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
  end

  it 'parses negative operation (2)' do
    result = @parser.parse("aa -bb")
    expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
  end

  it 'parses quoted string' do
    result = @parser.parse('"aa bb"')
    expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
  end

  [' AND ', '&', ' & ', ' OR ', '|', ' | '].each do |land|
    context "parses '#{land}' "  do
      it 'operation' do
        result = @parser.parse("aa#{land}bb")
        expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
      end

      it 'operations' do
        result = @parser.parse("aa#{land}bb#{land}cc")
        expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
      end

      it 'operation with parentheses' do
        result = @parser.parse("(aa#{land}bb)")
        expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
      end
    end
  end

  [
    [' OR ', ' AND '],
    [' | ', ' & '],
    ['|', '&']
  ].each do |l1, l2|

    context "parses '#{l1}' and '#{l2}' operations" do
      it '(1)' do
        result = @parser.parse("(aa#{l1}bb)#{l2}cc")
        expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
      end

      it '(2)' do
        result = @parser.parse("aa#{l1}(bb#{l2}cc)")
        expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
      end
    end

  end

  it 'parses complex operations (1)' do
    result = @parser.parse("(aa OR bb) AND (cc OR dd)")
    expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
  end

  it 'parses complex operations (2)' do
    result = @parser.parse('"aa bb" AND -"cc dd" AND (ee OR ff)')
    expect(result).to be_a_kind_of Treetop::Runtime::SyntaxNode
  end

  it 'returns nil if it cannot parse input string' do
    result = @parser.parse("a AND b (c AND d)")
    expect(result).to be nil
  end
end
