require 'spec_helper'
require 'active_record_helper'
require 'logical_query_parser/nodes/active_record'

describe LogicalQueryParser::ActiveRecord do
  let(:parser) { LogicalQueryParser.new }
  let(:opts) { { model: Doc, columns: %w(title body) } }

  context 'without operator' do
    it 'parses one word' do
      result = parser.parse("aa").to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses multiple words' do
      result = parser.parse("aa bb cc").to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses quoted words' do
      result = parser.parse('"aa bb"').to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end
  end

  ['NOT ', '- ', '-'].each do |ope|
    context "with #{ope} operator" do
      it 'before word (1)' do
        result = parser.parse("#{ope}aa bb").to_sql(opts)
        expect(result).not_to be_empty
        expect(Doc.where(result).to_a).not_to be_nil
      end

      it 'before word (2)' do
        result = parser.parse("aa #{ope}bb").to_sql(opts)
        expect(result).not_to be_empty
        expect(Doc.where(result).to_a).not_to be_nil
      end

      it 'before parenthesis (1)' do
        result = parser.parse("#{ope}(aa OR bb)").to_sql(opts)
        expect(result).not_to be_empty
        expect(Doc.where(result).to_a).not_to be_nil
      end

      it 'before parenthesis (2)' do
        result = parser.parse("(aa OR bb) AND #{ope}(cc OR dd)").to_sql(opts)
        expect(result).not_to be_empty
        expect(Doc.where(result).to_a).not_to be_nil
      end
    end
  end

  [['AND', %w(AND & &&)], ['OR', %w(OR | ||)]].each do |logic, opes|
    opes.each do |ope|
      context "with #{ope} operator" do
        it 'parses multiple words' do
          result = parser.parse("aa #{ope} bb #{ope} cc").to_sql(opts)
          expect(result).not_to be_empty
          expect(Doc.where(result).to_a).not_to be_nil
        end

        it 'parses with parenthesis' do
          result = parser.parse("(aa #{ope} bb)").to_sql(opts)
          expect(result).not_to be_empty
          expect(Doc.where(result).to_a).not_to be_nil
        end
      end
    end
  end

  context 'with complex expression' do
    it 'parses (1)' do
      result = parser.parse("(aa OR bb) AND cc").to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (2)' do
      result = parser.parse("aa AND (bb OR cc)").to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (3)' do
      result = parser.parse("(aa OR bb) AND (cc OR dd)").to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (4)' do
      result = parser.parse('"aa bb" AND NOT "cc dd" AND (ee OR ff)').to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end
  end

  context 'with ambiguous expression' do
    it 'parses (1)' do
      result = parser.parse("aa bb OR cc").to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (2)' do
      result = parser.parse("aa (bb OR cc)").to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (3)' do
      result = parser.parse("(aa OR bb) cc").to_sql(opts)
      expect(result).not_to be_empty
      expect(Doc.where(result).to_a).not_to be_nil
    end
 end

  context 'with invalid syntax' do
    it 'returns nil (1)' do
      result = parser.parse("AND")
      expect(result).to be_nil
    end

    it 'returns nil (2)' do
      result = parser.parse("NOT AND")
      expect(result).to be_nil
    end
  end
end
