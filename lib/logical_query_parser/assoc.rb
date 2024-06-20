# frozen_string_literal: true

module LogicalQueryParser
  class Assoc
    attr_accessor :column_mapping, :structure
    attr_accessor :current

    def initialize(attrs = {})
      @column_mapping = {}
      @structure = {}
    end
  end
end
