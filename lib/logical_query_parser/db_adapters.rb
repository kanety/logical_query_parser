# frozen_string_literal: true

module LogicalQueryParser
  module DbAdapters
    class << self
      def resolve(connection)
        case connection.adapter_name
        when 'PostgreSQL', 'PostGIS'
          require 'logical_query_parser/db_adapters/pg'
          DbAdapters::Pg
        when 'Mysql2', 'Trilogy'
          require 'logical_query_parser/db_adapters/mysql'
          DbAdapters::Mysql
        when 'SQLite'
          require 'logical_query_parser/db_adapters/sqlite'
          DbAdapters::Sqlite
        else
          raise NotImplementedError, "Unsupported adapter: #{connection.adapter_name}"
        end
      end
    end
  end
end
