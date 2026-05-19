require 'logical_query_parser/assoc_resolver'
require 'active_record_helper'

describe LogicalQueryParser::AssocResolver do
  context 'without associations' do
    it 'resolves columns' do
      root = LogicalQueryParser::AssocResolver.new(Doc.all, :title, :body).call
      expect(root.assoc_name).to eq(nil)
      expect(root.table_name).to eq(Doc.table_name)
      expect(root.columns).to eq([:title, :body])
      expect(root.join_structure).to eq({})
    end
  end

  context 'with associations' do
    it 'resolves single association' do
      root = LogicalQueryParser::AssocResolver.new(Doc.all, :title, :body, tags: [:name]).call
      tags = root.descendants.detect { |a| a.assoc_name == :tags }
      expect(tags.table_name).to eq(Tag.table_name)
      expect(tags.columns).to eq([:name])
      expect(root.join_structure).to eq(tags: {})
    end

    it 'resolves multiple associations' do
      root = LogicalQueryParser::AssocResolver.new(Doc.all, :title, :body, tags: [:name], flags: [:name]).call
      tags = root.descendants.detect { |a| a.assoc_name == :tags }
      flags = root.descendants.detect { |a| a.assoc_name == :flags }
      expect(tags.table_name).to eq(Tag.table_name)
      expect(tags.columns).to eq([:name])
      expect(flags.table_name).to eq(Flag.table_name)
      expect(flags.columns).to eq([:name])
      expect(root.join_structure).to eq(tags: {}, flags: {})
    end

    it 'resolves nested associations' do
      root = LogicalQueryParser::AssocResolver.new(Doc.all, :title, :body, tags: [:name, users: [:name]]).call
      tags = root.descendants.detect { |a| a.assoc_name == :tags }
      users = tags.descendants.detect { |a| a.assoc_name == :users }
      expect(tags.table_name).to eq(Tag.table_name)
      expect(tags.columns).to eq([:name])
      expect(users.table_name).to eq(User.table_name)
      expect(users.columns).to eq([:name])
      expect(root.join_structure).to eq(tags: { users: {} })
    end

    it 'resolves associations joined with alias name' do
      root = LogicalQueryParser::AssocResolver.new(Doc.all, :title, :body, tags: [:name, doc: [:title]]).call
      tags = root.descendants.detect { |a| a.assoc_name == :tags }
      doc = tags.descendants.detect { |a| a.assoc_name == :doc }
      expect(root.table_name).to eq(Doc.table_name)
      expect(root.columns).to eq([:title, :body])
      expect(tags.table_name).to eq(Tag.table_name)
      expect(tags.columns).to eq([:name])
      expect(doc.table_name).to eq('docs_tags')
      expect(doc.columns).to eq([:title])
      expect(root.join_structure).to eq(tags: { doc: {} })
    end
  end
end
