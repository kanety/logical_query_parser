module LogicalQueryParser
  module ExpNode
    def to_sql(params = {})
      params[:sql] ||= ''
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
        params[:sql] += ' AND '
        rexp.elements[0].to_sql(params)
      end
      params[:sql]
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
      params[:sql] << ' AND '
      exp.to_sql(params)
    end
  end

  module LParenNode
    def to_sql(params)
      params[:sql] << '('
    end
  end

  module RParenNode
    def to_sql(params)
      params[:sql] << ')'
    end
  end

  module AndNode
    def to_sql(params)
      params[:sql] << ' AND '
    end
  end

  module OrNode
    def to_sql(params)
      params[:sql] << ' OR '
    end
  end

  module NotNode
    def to_sql(params)
      params[:sql] << 'NOT '
    end
  end

  module LiteralNode
    def to_sql(params)
      operator, logic = operator_and_logic
      text = LogicalQueryParser.unquote(word.text_value)
      
      sql = build_arel(params, operator, text).reduce(logic).to_sql
      sql = "(#{sql})" if sql[0] != '(' && sql[-1] != ')'
      params[:sql] << sql
    end

    private

    def operator_and_logic
      if negative.elements.size > 0
        return :does_not_match, :and
      else
        return :matches, :or
      end
    end

    def build_arel(params, operator, text)
      if params[:columns].is_a?(Hash)
        build_arel_from_hash(params[:model], params[:columns], operator, text)
      else
        build_arel_from_columns(params[:model], params[:columns], operator, text)
      end
    end
    
    def build_arel_from_columns(klass, columns, operator, text)
      columns.map { |column| klass.arel_table[column].send(operator, Arel.sql(klass.connection.quote("%#{text}%"))) }
    end

    def build_arel_from_hash(klass, hash, operator, text)
      hash.flat_map do |klass, columns|
        build_arel_from_columns(klass, columns, operator, text)
      end
    end
  end

  class << self
    def unquote(str)
      str = str[1..-2].to_s.gsub(/\\(.)/, '\1') if str[0] == '"' && str[-1] == '"'
      str
    end
  end
end
