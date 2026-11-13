# frozen_string_literal: true

module LogicalQueryParser
  module DbAdapters
    module Pg
      class << self
        def cast_to_text(arel)
          Arel::Nodes::NamedFunction.new('CAST', [arel.as('TEXT')])
        end

        def json_extract(arel, keys)
          args = [arel] + keys.map { |key| Arel::Nodes.build_quoted(key) }
          Arel::Nodes::NamedFunction.new('jsonb_extract_path_text', args)
        end
      end
    end
  end
end
