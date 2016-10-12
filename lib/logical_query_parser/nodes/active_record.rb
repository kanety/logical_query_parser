module LogicalQuery
  module ExpNode
    def to_sql(opts = {}, sql = '')
      any.to_sql(opts, sql)
    end
  end

  module ExpParenNode
    def to_sql(opts, sql = '')
      lparen.to_sql(opts, sql)
      exp.to_sql(opts, sql)
      rparen.to_sql(opts, sql)
    end
  end

  module CondNode
    def to_sql(opts, sql = '')
      lexp.to_sql(opts, sql)
      logic.to_sql(opts, sql)
      rexp.to_sql(opts, sql)
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

  module LiteralSeqNode
    def to_sql(opts, sql = '')
      lliteral.to_sql(opts, sql)
      sql << ' AND '
      rliteral.to_sql(opts, sql)
    end
  end

  module LiteralNode
    def to_sql(opts, sql = '')
      operator, logic = negative.elements.size > 0 ? [:does_not_match, :and] : [:matches, :or]
      unquoted = LogicalQuery.unquote(word.text_value)

      arel_table = opts[:model].arel_table
      relations = opts[:columns].map { |c| arel_table[c].send(operator, "%#{unquoted}%") }.reduce(logic)
      sql << relations.to_sql
    end
  end

  class << self
    def unquote(str)
      str = str[1..-2].to_s.gsub(/\\(.)/, '\1') if str[0] == '"' && str[-1] == '"'
      str
    end
  end
end
