# frozen_string_literal: true

# See README.me for the descriptions.

module BlankEmptyNilFilters
  module ArrayExtensions
    def no_empty_values
      reject_values(:is_empty?)
    end
    alias reject_empty_values no_empty_values

    def no_blank_values
      reject_values(:is_blank?)
    end
    alias reject_blank_values no_blank_values

    def no_nil_values
      reject_values(:nil?)
    end
    alias reject_nil_values no_nil_values

    def only_empty_values
      select_values(:is_empty?)
    end

    def only_blank_values
      select_values(:is_blank?)
    end

    def only_nil_values
      select_values(:is_nil?)
    end

    def is_empty?
      length.zero? || reject_empty_values.length.zero?
    end

    def is_blank?
      is_empty? || reject_blank_values.length.zero?
    end

    def reject_values(filter)
      map { |val| val.respond_to?(:reject_values) ? val.reject_values(filter) : val }
        .reject { |val| val.send(filter) }
    end
    alias no_values reject_values

    def select_values(filter)
      map { |val| val.respond_to?(:select_values) ? val.select_values(filter) : val }
        .select { |val| val.send(filter) }
    end
    alias only_values select_values
  end

  module HashExtensions
    def no_empty_values
      reject_values(:is_empty?)
    end
    alias reject_empty_values no_empty_values

    def only_empty_values
      select_values(:is_empty?)
    end
    alias select_empty_values only_empty_values

    def no_blank_values
      reject_values(:is_blank?)
    end
    alias reject_blank_values no_blank_values

    def only_blank_values
      select_values(:is_blank?)
    end
    alias select_blank_values only_blank_values

    def no_nil_values
      reject_values(:nil?)
    end
    alias reject_nil_values no_nil_values

    def only_nil_values
      select_values(:nil?)
    end
    alias select_nil_values only_nil_values

    def empty_value_keys
      only_empty_values.keys
    end

    def blank_value_keys
      only_blank_values.key
    end

    def nil_value_keys
      only_nil_values.keys
    end

    def non_empty_value_keys
      no_empty_values.key
    end

    def non_blank_value_keys
      no_blank_values.keys
    end

    def non_nil_value_keys
      no_nil_values.keys
    end

    def is_empty?
      length.zero? || no_empty_values.length.zero?
    end

    def is_blank?
      length.zero? || reject_blank_values.length.zero?
    end

    def reject_values(filter)
      dup.transform_values { |val| val.respond_to?(:reject_values) ? val.reject_values(filter) : val }
         .reject { |_key, val| val.send(filter) }
    end

    def select_values(filter)
      dup.transform_values { |val| val.respond_to?(:select_values) ? val.select_values(filter) : val }
         .select { |_key, val| val.send(filter) }
    end
  end

  module StringExtensions
    def is_empty?
      length.zero?
    end

    def is_blank?
      is_empty? || strip.length.zero?
    end
  end

  module NilClassExtensions
    def is_empty?
      true
    end

    def is_blank?
      true
    end

    def is_nil?
      true
    end
  end

  module ObjectExtensions
    def is_empty?
      if nil?
        true
      elsif respond_to?(:length) && Numeric === length
        length.zero?
      elsif respond_to?(:size) && Numeric === size
        size.zero?
      else
        false
      end
    end

    def non_empty?
      !is_empty?
    end

    def is_blank?
      is_empty? || to_s.is_blank?
    end

    def non_blank?
      !is_blank?
    end

    def non_nil?
      !nil?
    end

    def is_nil?
      nil?
    end
  end
end

require_relative 'blank_empty_nil_filters/version'

# prepend these extension methods on these classes
Array.prepend    BlankEmptyNilFilters::ArrayExtensions
Hash.prepend     BlankEmptyNilFilters::HashExtensions
String.prepend   BlankEmptyNilFilters::StringExtensions
NilClass.prepend BlankEmptyNilFilters::NilClassExtensions
Object.prepend   BlankEmptyNilFilters::ObjectExtensions
