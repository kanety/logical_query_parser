require 'spec_helper'
require 'active_record_helper'
require 'logical_query_parser/nodes/active_record'

describe LogicalQueryParser do
  let(:parser) { LogicalQueryParser.new }
  let(:options) { { model: Doc, columns: %w(title body) } }

  context 'without operator' do
    it 'parses one word' do
      result = parser.parse("aa").to_sql(options)
      debug(result)
      expect(result).to match sequence %w|title aa OR body aa|
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses multiple words' do
      result = parser.parse("aa bb cc").to_sql(options)
      debug(result)
      expect(result).to match sequence %w|( title aa OR body aa ) AND ( title bb OR body bb ) AND ( title cc OR body cc )|
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses quoted words' do
      result = parser.parse('"aa bb"').to_sql(options)
      debug(result)
      expect(result).to match sequence %w|title aa\ bb OR body aa\ bb|
      expect(Doc.where(result).to_a).not_to be_nil
    end
  end

  ['NOT ', '- ', '-'].each do |ope|
    context "with #{ope} operator" do
      it 'before word (1)' do
        result = parser.parse("#{ope}aa bb").to_sql(options)
        debug(result)
        expect(result).to match sequence %w|( title NOT aa AND body NOT aa ) AND ( title bb OR body bb )|
        expect(Doc.where(result).to_a).not_to be_nil
      end

      it 'before word (2)' do
        result = parser.parse("aa #{ope}bb").to_sql(options)
        debug(result)
        expect(result).to match sequence %w|( title aa OR body aa ) AND ( title NOT bb AND body NOT bb )|
        expect(Doc.where(result).to_a).not_to be_nil
      end

      it 'before parenthesis (1)' do
        result = parser.parse("#{ope}(aa OR bb)").to_sql(options)
        debug(result)
        expect(result).to match sequence %w|NOT ( ( title aa OR body aa ) OR ( title bb OR body bb ) )|
        expect(Doc.where(result).to_a).not_to be_nil
      end

      it 'before parenthesis (2)' do
        result = parser.parse("(aa OR bb) AND #{ope}(cc OR dd)").to_sql(options)
        debug(result)
        expect(result).to match sequence %w|( ( title aa OR body aa ) OR ( title bb OR body bb ) ) AND NOT ( ( title cc OR body cc ) OR ( title dd OR body dd ) )|
        expect(Doc.where(result).to_a).not_to be_nil
      end
    end
  end

  [['AND', %w(AND & &&)], ['OR', %w(OR | ||)]].each do |logic, opes|
    opes.each do |ope|
      context "with #{ope} operator" do
        it 'parses multiple words' do
          result = parser.parse("aa #{ope} bb #{ope} cc").to_sql(options)
          debug(result)
          expect(result).to match sequence %W|( title aa OR body aa ) #{logic} ( title bb OR body bb ) #{logic} ( title cc OR body cc )|
          expect(Doc.where(result).to_a).not_to be_nil
        end

        it 'parses with parenthesis' do
          result = parser.parse("(aa #{ope} bb)").to_sql(options)
          debug(result)
          expect(result).to match sequence %W|( title aa OR body aa ) #{logic} ( title bb OR body bb )|
          expect(Doc.where(result).to_a).not_to be_nil
        end
      end
    end
  end

  context 'with complex expression' do
    it 'parses (1)' do
      result = parser.parse("(aa OR bb) AND cc").to_sql(options)
      debug(result)
      expect(result).to match sequence %W|( ( title aa OR body aa ) OR ( title bb OR body bb ) ) AND ( title cc OR body cc )|
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (2)' do
      result = parser.parse("aa AND (bb OR cc)").to_sql(options)
      debug(result)
      expect(result).to match sequence %W|( title aa OR body aa ) AND ( ( title bb OR body bb ) OR ( title cc OR body cc ) )|
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (3)' do
      result = parser.parse("(aa OR bb) AND (cc OR dd)").to_sql(options)
      debug(result)
      expect(result).to match sequence %W|( ( title aa OR body aa ) OR ( title bb OR body bb ) ) AND ( ( title cc OR body cc ) OR ( title dd OR body dd ) )|
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (4)' do
      result = parser.parse('"aa bb" AND NOT "cc dd" AND (ee OR ff)').to_sql(options)
      debug(result)
      expect(result).to match sequence %W|( title aa\ bb OR body aa\ bb ) AND ( title NOT cc\ dd AND body NOT cc\ dd ) AND ( ( title ee OR body ee ) OR ( title ff OR body ff ) )|
      expect(Doc.where(result).to_a).not_to be_nil
    end
  end

  context 'with ambiguous expression' do
    it 'parses (1)' do
      result = parser.parse("aa bb OR cc").to_sql(options)
      debug(result)
      expect(result).to match sequence %W|( title aa OR body aa ) AND ( title bb OR body bb ) OR ( title cc OR body cc )|
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (2)' do
      result = parser.parse("aa (bb OR cc)").to_sql(options)
      debug(result)
      expect(result).to match sequence %W|( title aa OR body aa ) AND ( ( title bb OR body bb ) OR ( title cc OR body cc ) )|
      expect(Doc.where(result).to_a).not_to be_nil
    end

    it 'parses (3)' do
      result = parser.parse("(aa OR bb) cc").to_sql(options)
      debug(result)
      expect(result).to match sequence %W|( ( title aa OR body aa ) OR ( title bb OR body bb ) ) AND ( title cc OR body cc )|
      expect(Doc.where(result).to_a).not_to be_nil
    end
  end

  context 'with invalid syntax' do
    it 'returns nil (1)' do
      result = parser.parse("AND")
      debug(result)
      expect(result).to be_nil
    end

    it 'returns nil (2)' do
      result = parser.parse("NOT AND")
      debug(result)
      expect(result).to be_nil
    end
  end

  context 'search' do
    it 'searches' do
      relations = LogicalQueryParser.search("aa AND bb", Doc, :title, :body)
      debug(relations.to_sql)
      expect(relations.to_sql).to match sequence %W|( ( title aa OR body aa ) AND ( title bb OR body bb )|
      expect(relations.to_a).not_to be_nil
    end

    it 'searches one association' do
      relations = LogicalQueryParser.search("aa AND bb", Doc, :title, { tags: :name })
      debug(relations.to_sql)
      expect(relations.to_sql).to match sequence %W|( ( title aa OR tags name aa ) AND ( title bb OR tags name bb )|
      expect(relations.to_a).not_to be_nil
    end

    it 'searches nested association' do
      relations = LogicalQueryParser.search("aa AND bb", Doc, :title, tags: [:name, users: :name])
      debug(relations.to_sql)
      expect(relations.to_sql).to match sequence %W|( ( ( title aa OR tags name aa ) OR users name aa ) AND ( ( title bb OR tags name bb ) OR users name bb )|
      expect(relations.to_a).not_to be_nil
    end

    it 'searches nested association with array' do
      relations = LogicalQueryParser.search("aa AND bb", Doc, [:title, tags: [:name, users: :name]])
      debug(relations.to_sql)
      expect(relations.to_sql).to match sequence %W|( ( ( title aa OR tags name aa ) OR users name aa ) AND ( ( title bb OR tags name bb ) OR users name bb )|
      expect(relations.to_a).not_to be_nil
    end
  end
end
