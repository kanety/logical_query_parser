# frozen_string_literal: true

require 'json'

module LogicalQueryParser
  module DbAdapters
    module Sqlite
      class << self
        def cast_to_text(arel)
          Arel::Nodes::NamedFunction.new('CAST', [arel.as('TEXT')])
        end

        def json_extract(arel, keys)
          json_path = '$' + keys.map { |key| ".#{key.to_json}" }.join
          Arel::Nodes::NamedFunction.new('JSON_EXTRACT', [arel, Arel::Nodes.build_quoted(json_path)])
        end
      end
    end
  end
end
