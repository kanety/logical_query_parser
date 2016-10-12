require 'spec_helper'

describe LogicalQueryParser do
  it 'has a version number' do
    expect(LogicalQuery::VERSION).not_to be nil
  end

  it 'walks on tree' do
    result = LogicalQueryParser.new.parse("aa AND bb")
    LogicalQueryParser.walk_tree(result) do |node|
      expect(node).to be_a_kind_of Treetop::Runtime::SyntaxNode
    end
  end
end
