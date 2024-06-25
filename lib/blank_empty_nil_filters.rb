# frozen_string_literal: true

# See README.me for the descriptions.

module BlankEmptyNilFilters
  # These filter methods are used on both the Array and Hash extensions
  module FilterMethods
    def maybe_recurse(val, scanner, condition, start, depth, level)
      if depth.nil? || level <= depth
        if val.respond_to?(scanner)
          val.send(scanner, condition, start, depth, level+1) # recurse
        else
          val
        end
      else
        val
      end
    end

    def maybe_apply(val, condition, default, start, depth, level)
      if level >= (start || 0) && (depth.nil? || level <= depth)
        val.send(condition)
      else
        default
      end
    end
  end

  module ArrayExtensions
    def no_empty_values(start = 0, depth = nil, level = 0)
      reject_values(:is_empty?, start, depth, level)
    end
    alias reject_empty_values no_empty_values

    def no_blank_values(start = 0, depth = nil, level = 0)
      reject_values(:is_blank?, start, depth, level)
    end
    alias reject_blank_values no_blank_values

    def no_nil_values(start = 0, depth = nil, level = 0)
      reject_values(:nil?, start, depth, level)
    end
    alias reject_nil_values no_nil_values

    def only_empty_values(start = 0, depth = nil, level = 0)
      select_values(:is_empty?, start, depth, level)
    end
    alias select_empty_values only_empty_values

    def only_blank_values(start = 0, depth = nil, level = 0)
      select_values(:is_blank?, start, depth, level)
    end
    alias select_blank_values only_blank_values

    def only_nil_values(start = 0, depth = nil, level = 0)
      select_values(:is_nil?, start, depth, level)
    end
    alias select_nil_values only_nil_values

    def is_empty?(start = 0, depth = nil, level = 0)
      length.zero? || no_empty_values(start, depth, level).length.zero?
    end

    def is_blank?(start = 0, depth = nil, level = 0)
      is_empty? || no_blank_values(start, depth, level).length.zero?
    end

    # @param [Symbol] condition the name of the filter method (eg: :is_empty?)
    # @param [Integer] start the starting level at which filtering occurs; default: 0
    # @param [Integer|nil] depth the maximum level at which filtering occurs; defaults to nil for no limit
    # @param [Integer] level the current level; defaults to 0
    # @return [Array] the filtered array after having recursively applied +condition+ to each
    #                 element and removing those for which the condition is true
    def reject_values(condition, start = 0, depth = nil, level = 0)
      filter_values(:reject_values, :reject, condition, start, depth, level)
    end
    alias no_values reject_values

    # @param [Symbol] condition the name of the filter method (eg: :is_empty?)
    # @param [Integer] start the starting level at which filtering occurs; default: 0
    # @param [Integer|nil] depth the maximum level at which filtering occurs; nil = no limit
    # @param [Integer] level the current level; defaults to 0
    # @return [Array] the filtered array after having recursively applied +condition+ to each element
    #                 element and selecting out those for which the condition is true
    def select_values(condition, start = 0, depth = nil, level = 0)
      filter_values(:select_values, :select, condition, start, depth, level)
    end
    alias only_values select_values

    private

    include FilterMethods

    def filter_values(scanner, selector, condition, start, depth, level)
      default = selector == :select
      map { |val| maybe_recurse(val, scanner, condition, start, depth, level) }
        .send(selector) { |val| maybe_apply(val, condition, default, start, depth, level) }
    end
  end

  module HashExtensions
    def no_empty_values(start = 0, depth = nil, level = 0)
      reject_values(:is_empty?, start, depth, level)
    end
    alias reject_empty_values no_empty_values

    def only_empty_values(start = 0, depth = nil, level = 0)
      select_values(:is_empty?, start, depth, level)
    end
    alias select_empty_values only_empty_values

    def no_blank_values(start = 0, depth = nil, level = 0)
      reject_values(:is_blank?, start, depth, level)
    end
    alias reject_blank_values no_blank_values

    def only_blank_values(start = 0, depth = nil, level = 0)
      select_values(:is_blank?, start, depth, level)
    end
    alias select_blank_values only_blank_values

    def no_nil_values(start = 0, depth = nil, level = 0)
      reject_values(:nil?, start, depth, level)
    end
    alias reject_nil_values no_nil_values

    def only_nil_values(start = 0, depth = nil, level = 0)
      select_values(:nil?, start, depth, level)
    end
    alias select_nil_values only_nil_values

    def empty_value_keys(start = 0, depth = nil, level = 0)
      only_empty_values(start, depth, level).keys
    end

    def blank_value_keys(start = 0, depth = nil, level = 0)
      only_blank_values(start, depth, level).keys
    end

    def nil_value_keys(start = 0, depth = nil, level = 0)
      only_nil_values(start, depth, level).keys
    end

    def non_empty_value_keys(start = 0, depth = nil, level = 0)
      no_empty_values(start, depth, level).keys
    end

    def non_blank_value_keys(start = 0, depth = nil, level = 0)
      no_blank_values(start, depth, level).keys
    end

    def non_nil_value_keys(start = 0, depth = nil, level = 0)
      no_nil_values(start, depth, level).keys
    end

    def is_empty?(start = 0, depth = nil, level = 0)
      length.zero? || no_empty_values(start, depth, level).length.zero?
    end

    def is_blank?(start = 0, depth = nil, level = 0)
      length.zero? || reject_blank_values(start, depth, level).length.zero?
    end

    def reject_values(condition, start = 0, depth = nil, level = 0)
      filter_hash_values(:reject_values, :reject, condition, start, depth, level)
    end

    def select_values(condition, start = 0, depth = nil, level = 0)
      filter_hash_values(:select_values, :select, condition, start, depth, level)
    end

    private

    include FilterMethods

    def filter_hash_values(scanner, selector, condition, start, depth, level)
      default = selector == :select
      dup.transform_values { |val| maybe_recurse(val, scanner, condition, start, depth, level) }
        .send(selector) { |_key, val| maybe_apply(val, condition, default, start, depth, level) }
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
    def no_blank_value
      is_blank? ? nil : self
    end
    alias non_blank no_blank_value

    def no_empty_value
      is_empty? ? nil : self
    end
    alias non_empty no_empty_value

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
