# frozen_string_literal: true

require_relative 'assoc'

module LogicalQueryParser
  class AssocResolver
    def initialize(klass)
      @klass = klass
    end

    def run(*args)
      Assoc.new.tap do |assoc|
        assoc.current = assoc.structure
        resolve_assocs(@klass, args, assoc)
      end
    end

    private

    def wrap_array(options)
      if options.is_a?(Array)
        options.flatten(1)
      else
        [options]
      end
    end

    def resolve_assocs(klass, options, assoc)
      options = wrap_array(options)
      options.each do |option|
        if option.is_a?(Hash)
          resolve_assocs_for_hash(klass, option, assoc)
        else
          assoc.column_mapping[klass] ||= []
          assoc.column_mapping[klass] << option
        end
      end
    end

    def resolve_assocs_for_hash(klass, hash, assoc)
      hash.each do |assoc_name, options|
        if (reflection = klass.reflect_on_association(assoc_name))
          assoc.current[assoc_name] = {}
          assoc.current = assoc.current[assoc_name]
          resolve_assocs(reflection.klass, options, assoc)
        end
      end
    end
  end
end
