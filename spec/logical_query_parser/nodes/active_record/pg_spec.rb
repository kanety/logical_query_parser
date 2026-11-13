require 'spec_helper'
require 'active_record_helper'
require 'logical_query_parser/nodes/active_record'

describe 'postgresql' do
  ['PostgreSQL', 'PostGIS'].each do |adapter|
    context "with #{adapter}" do
      let!(:original_adapter_name) { Doc.connection.adapter_name }

      before do
        allow(Doc.connection).to receive(:adapter_name).and_return(adapter)
      end

      it 'casts non-text columns' do
        relation = LogicalQueryParser.search('99', Doc, :rank)
        debug(relation.to_sql)
        expect(relation.to_sql).to match sequence %W|CAST ( docs rank AS TEXT ) 99|
        expect(relation.to_a).not_to be_nil if Doc.connection.adapter_name == original_adapter_name
      end

      it 'parses JSON path' do
        relation = LogicalQueryParser.search('aa', Doc, 'data->key1->key2')
        debug(relation.to_sql)
        expect(relation.to_sql).to match sequence %W|CAST ( jsonb_extract_path_text ( docs data key1 key2 ) AS TEXT ) aa|
        expect(relation.to_a).not_to be_nil if Doc.connection.adapter_name == original_adapter_name
      end
    end
  end
end
