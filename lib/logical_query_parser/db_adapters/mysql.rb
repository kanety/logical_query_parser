# frozen_string_literal: true

require 'json'

module LogicalQueryParser
  module DbAdapters
    module Mysql
      class << self
        def cast_to_text(arel)
          Arel::Nodes::NamedFunction.new('CAST', [arel.as('CHAR')])
        end

        def json_extract(arel, key)
          json_path = '$' + key.map { |key| ".#{key.to_json}" }.join
          json_extract = Arel::Nodes::NamedFunction.new('JSON_EXTRACT', [arel, Arel::Nodes.build_quoted(json_path)])
          Arel::Nodes::NamedFunction.new('JSON_UNQUOTE', [json_extract])
        end
      end
    end
  end
end
