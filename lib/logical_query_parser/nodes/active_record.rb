module LogicalQueryParser
  module ExpNode
    def to_sql(opts = {}, sql = '')
      exp.to_sql(opts, sql)
    end
  end

  module ParenExpNode
    def to_sql(opts, sql = '')
      if negative.elements.size > 0
        negative.elements[0].to_sql(opts, sql)
      end
      lparen.to_sql(opts, sql)
      exp.to_sql(opts, sql)
      rparen.to_sql(opts, sql)
      if rexp.elements.size > 0
        sql += ' AND '
        rexp.elements[0].to_sql(opts, sql)
      end
      sql
    end
  end

  module LogicExpNode
    def to_sql(opts, sql = '')
      lexp.to_sql(opts, sql)
      logic.to_sql(opts, sql)
      rexp.to_sql(opts, sql)
    end
  end

  module LiteralExpNode
    def to_sql(opts, sql = '')
      literal.to_sql(opts, sql)
      sql << ' AND '
      exp.to_sql(opts, sql)
    end
  end

  module LParenNode
    def to_sql(opts, sql = '')
      sql << '('
    end
  end

  module RParenNode
    def to_sql(opts, sql = '')
      sql << ')'
    end
  end

  module AndNode
    def to_sql(opts, sql = '')
      sql << ' AND '
    end
  end

  module OrNode
    def to_sql(opts, sql = '')
      sql << ' OR '
    end
  end

  module NotNode
    def to_sql(opts, sql = '')
      sql << 'NOT '
    end
  end

  module LiteralNode
    def to_sql(opts, sql = '')
      operator, logic = negative.elements.size > 0 ? [:does_not_match, :and] : [:matches, :or]
      unquoted = LogicalQueryParser.unquote(word.text_value)

      arel = opts[:model].arel_table
      ss = opts[:columns].map { |c| arel[c].send(operator, "%#{unquoted}%") }.reduce(logic).to_sql
      ss = "(#{ss})" if ss[0] != '(' && ss[-1] != ')'
      sql << ss
    end
  end

  class << self
    def unquote(str)
      str = str[1..-2].to_s.gsub(/\\(.)/, '\1') if str[0] == '"' && str[-1] == '"'
      str
    end
  end
end
