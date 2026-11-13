# frozen_string_literal: true

require 'logical_query_parser/db_adapters'

module LogicalQueryParser
  module ExpNode
    def to_sql(params = {})
      params[:_sql] ||= ''.dup
      exp.to_sql(params)
    end
  end

  module ParenExpNode
    def to_sql(params)
      if negative.elements.size > 0
        negative.elements[0].to_sql(params)
      end
      lparen.to_sql(params)
      exp.to_sql(params)
      rparen.to_sql(params)
      if rexp.elements.size > 0
        params[:_sql] += ' AND '
        rexp.elements[0].to_sql(params)
      end
      params[:_sql]
    end
  end

  module LogicExpNode
    def to_sql(params)
      lexp.to_sql(params)
      logic.to_sql(params)
      rexp.to_sql(params)
    end
  end

  module LiteralExpNode
    def to_sql(params)
      literal.to_sql(params)
      params[:_sql] << ' AND '
      exp.to_sql(params)
    end
  end

  module LParenNode
    def to_sql(params)
      params[:_sql] << '('
    end
  end

  module RParenNode
    def to_sql(params)
      params[:_sql] << ')'
    end
  end

  module AndNode
    def to_sql(params)
      params[:_sql] << ' AND '
    end
  end

  module OrNode
    def to_sql(params)
      params[:_sql] << ' OR '
    end
  end

  module NotNode
    def to_sql(params)
      params[:_sql] << 'NOT '
    end
  end

  module LiteralNode
    def to_sql(params)
      operator, logic = operator_and_logic
      text = LogicalQueryParser.unquote(word.text_value)
      
      sql = build_arel(params[:root], operator, text).reduce(logic).to_sql
      sql = "(#{sql})" if sql[0] != '(' && sql[-1] != ')'
      params[:_sql] << sql
    end

    private

    def operator_and_logic
      if negative.elements.size > 0
        return :does_not_match, :and
      else
        return :matches, :or
      end
    end

    def build_arel(root, operator, text)
      assocs = [root] + root.descendants
      assocs.flat_map do |assoc|
        assoc.columns.map do |column|
          if column.to_s.include?('->')
            arel = build_json_arel(assoc, column)
          else
            arel = build_text_arel(assoc, column)
          end
          arel.send(operator, Arel.sql(assoc.klass.connection.quote("%#{text}%")))
        end
      end
    end

    def build_text_arel(assoc, column)
      connection = assoc.klass.connection
      arel = assoc.arel_table[column]
      arel = DbAdapters.resolve(connection).cast_to_text(arel) unless text_column?(assoc, column)
      arel
    end

    def build_json_arel(assoc, column_and_keys)
      connection = assoc.klass.connection
      column, *keys = column_and_keys.to_s.split('->', -1)

      arel = assoc.arel_table[column]
      adapter = DbAdapters.resolve(connection)
      adapter.cast_to_text(adapter.json_extract(arel, keys))
    end

    def text_column?(assoc, column)
      [:string, :text].include?(assoc.klass.columns_hash[column.to_s].type)
    end
  end

  class << self
    def unquote(str)
      str = str[1..-2].to_s.gsub(/\\(.)/, '\1') if str[0] == '"' && str[-1] == '"'
      str
    end
  end
end
