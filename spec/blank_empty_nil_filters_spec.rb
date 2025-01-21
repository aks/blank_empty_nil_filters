# frozen_string_literal: true

require 'spec_helper'
require 'blank_empty_nil_filters'

RSpec.describe BlankEmptyNilFilters do
  DESC_INDEX              = 0
  DATA_INDEX              = 1

  NON_EMPTY_RESULT_INDEX  = 2
  NON_BLANK_RESULT_INDEX  = 3
  NON_NIL_RESULT_INDEX    = 4

  ONLY_EMPTY_RESULT_INDEX = 5
  ONLY_BLANK_RESULT_INDEX = 6
  ONLY_NIL_RESULT_INDEX   = 7

  shared_examples_for 'apply_filter' do |test_data, filter, method, result_index, test_kind|
    describe "##{method}" do
      test_data.each do |data|
        desc, test_datum, test_result = data.values_at(DESC_INDEX, DATA_INDEX, result_index)
        it "#{filter} #{test_kind} #{desc}" do
          expect(test_datum.send(method)).to eq test_result
        end
      end
    end
  end

  shared_examples_for 'filter_values' do |test_data, filter, condition, result_index, test_kind|
    filter_method = filter.to_s.sub(/s$/, '_values')
    describe "#{filter_method}(:#{condition})" do
      test_data.each do |data|
        desc, test_datum, test_result = data.values_at(DESC_INDEX, DATA_INDEX, result_index)
        it "#{filter} #{test_kind} #{desc}" do
          expect(test_datum.send(filter_method, condition)).to eq test_result
        end
      end
    end
  end

  shared_examples_for 'key_filters' do |test_data, filter, method, result_index, test_kind|
    describe "#{method}" do
      test_data.each do |data|
        desc, test_datum, test_result = data.values_at(DESC_INDEX, DATA_INDEX, result_index)
        it "#{filter} #{test_kind} #{desc}" do
          expect(test_datum.send(method)).to match_array(test_result.keys)
        end
      end
    end
  end

  METHODS_TO_RESULT_INDEX_MAP =
    {
      reject_empty_values: NON_EMPTY_RESULT_INDEX,
      reject_blank_values: NON_BLANK_RESULT_INDEX,
      reject_nil_values:   NON_NIL_RESULT_INDEX,
      select_empty_values: ONLY_EMPTY_RESULT_INDEX,
      select_blank_values: ONLY_BLANK_RESULT_INDEX,
      select_nil_values:   ONLY_NIL_RESULT_INDEX
    }.freeze

  shared_examples_for 'apply_filters_with_args' do |test_data, start, depth|
    %w[reject select].each do |filter|
      %w[empty blank nil].each do |kind|
        filter_method = "#{filter}_#{kind}_values".to_sym
        result_index = METHODS_TO_RESULT_INDEX_MAP[filter_method]
        test_kind = "#{filter}s #{kind} values"
        desc, test_datum, test_result = test_data.values_at(DESC_INDEX, DATA_INDEX, result_index)
        it "#{filter_method}(#{start || 'nil'}, #{depth || 'nil'}) #{test_kind} #{desc}" do
          expect(test_datum.send(filter_method, start, depth)).to eq test_result
        end
      end
    end
  end

  BOOL_DATA_INDEX     = 0
  BOOL_IS_EMPTY_INDEX = 1
  BOOL_IS_BLANK_INDEX = 2
  BOOL_DESC_INDEX     = 3

  shared_examples_for 'boolean_methods' do |test_data_set, method, result_index|
    describe "##{method}" do
      test_data_set.each do |data|
        test_data, test_result, description = data.values_at(BOOL_DATA_INDEX, result_index, BOOL_DESC_INDEX)
        it "returns #{test_result} on #{description}" do
          expect(test_data.send(method)).to be test_result
        end
      end
    end
  end

  describe "ArrayFilters" do
    context 'reject and select methods' do
      test_array_data =
        [
          [
            'array values',                       # description
            [1, 'foo', nil, :apple, ' '],         # test data

            [1, 'foo',      :apple, ' '],         # non empty result
            [1, 'foo',      :apple     ],         # non blank result
            [1, 'foo',      :apple, ' '],         # non nil result

            [          nil,            ],         # only empty result
            [          nil,         ' '],         # only blank result
            [          nil,            ],         # only nil result
          ],
          [
            'array values with sub-array elements',                     # description
            [1, 'foo',  nil, [:apple, nil, 'banana', ' ', ''], 'bar'],  # test_data

            [1, 'foo',       [:apple,      'banana', ' '    ], 'bar'],  # non empty result
            [1, 'foo',       [:apple,      'banana'         ], 'bar'],  # non blank result
            [1, 'foo',       [:apple,      'banana', ' ', ''], 'bar'],  # non nil result

            [           nil, [        nil,                ''],      ],  # only empty result
            [           nil, [        nil,           ' ', ''],      ],  # only blank result
            [           nil,                                        ],  # only nil result
          ],
          [
            'array values with sub-hash elements',                             # description
            [1, 'foo',  nil, { a: 1, b: nil, c: '', d: 'ok', e: ' ' }, 'bar'], # test data

            [1, 'foo',       { a: 1,                d: 'ok', e: ' ' }, 'bar'], # non empty result
            [1, 'foo',       { a: 1,                d: 'ok'         }, 'bar'], # non blank result
            [1, 'foo',       { a: 1,         c: '', d: 'ok', e: ' ' }, 'bar'], # non nil result

            [           nil, {       b: nil, c: '',                 },      ], # only empty result
            [           nil, {       b: nil, c: '',          e: ' ' },      ], # only blank result
            [           nil,                                                ], # only nil result
          ]
        ].freeze

      it_behaves_like 'apply_filter', test_array_data, :rejects, :no_empty_values,   NON_EMPTY_RESULT_INDEX,  'empty or nil'
      it_behaves_like 'apply_filter', test_array_data, :rejects, :no_blank_values,   NON_BLANK_RESULT_INDEX,  'blank or nil'
      it_behaves_like 'apply_filter', test_array_data, :rejects, :no_nil_values,     NON_NIL_RESULT_INDEX,    'nil'

      it_behaves_like 'apply_filter', test_array_data, :rejects, :reject_empty_values, NON_EMPTY_RESULT_INDEX, 'empty or nil'
      it_behaves_like 'apply_filter', test_array_data, :rejects, :reject_blank_values, NON_BLANK_RESULT_INDEX, 'blank or nil'
      it_behaves_like 'apply_filter', test_array_data, :rejects, :reject_nil_values,   NON_NIL_RESULT_INDEX,   'nil'

      it_behaves_like 'apply_filter', test_array_data, :selects, :only_empty_values, ONLY_EMPTY_RESULT_INDEX, 'empty or nil'
      it_behaves_like 'apply_filter', test_array_data, :selects, :only_blank_values, ONLY_BLANK_RESULT_INDEX, 'blank or nil'
      it_behaves_like 'apply_filter', test_array_data, :selects, :only_nil_values,   ONLY_NIL_RESULT_INDEX,   'nil'

      it_behaves_like 'apply_filter', test_array_data, :selects, :select_empty_values, ONLY_EMPTY_RESULT_INDEX, 'empty or nil'
      it_behaves_like 'apply_filter', test_array_data, :selects, :select_blank_values, ONLY_BLANK_RESULT_INDEX, 'blank or nil'
      it_behaves_like 'apply_filter', test_array_data, :selects, :select_nil_values,   ONLY_NIL_RESULT_INDEX,   'nil'

      it_behaves_like 'filter_values', test_array_data, :rejects, :is_empty?, NON_EMPTY_RESULT_INDEX,  'empty or nil'
      it_behaves_like 'filter_values', test_array_data, :rejects, :is_blank?, NON_BLANK_RESULT_INDEX,  'blank or nil'
      it_behaves_like 'filter_values', test_array_data, :rejects, :nil?,      NON_NIL_RESULT_INDEX,    'nil'

      it_behaves_like 'filter_values', test_array_data, :selects, :is_empty?, ONLY_EMPTY_RESULT_INDEX, 'empty or nil'
      it_behaves_like 'filter_values', test_array_data, :selects, :is_blank?, ONLY_BLANK_RESULT_INDEX, 'blank or nil'
      it_behaves_like 'filter_values', test_array_data, :selects, :nil?,      ONLY_NIL_RESULT_INDEX,   'nil'
    end

    context 'with start and depth arguments on array filters' do
      test_array_data_plain_0_nil =
        [
          'array values',               # description
          [1, 'foo', nil, :apple, ' '], # test data

          [1, 'foo',      :apple, ' '], # non empty result
          [1, 'foo',      :apple     ], # non blank result
          [1, 'foo',      :apple, ' '], # non nil result

          [          nil,            ], # only empty result
          [          nil,         ' '], # only blank result
          [          nil,            ], # only nil result
        ].freeze
      test_array_data_plain_1_nil =
        [
          'plain array values',         # description
          [1, 'foo', nil, :apple, ' '], # test data

          [1, 'foo', nil, :apple, ' '], # (1, nil) non empty result
          [1, 'foo', nil, :apple, ' '], # (1, nil) non blank result
          [1, 'foo', nil, :apple, ' '], # (1, nil) non nil result

          [1, 'foo', nil, :apple, ' '], # (1, nil) only empty result
          [1, 'foo', nil, :apple, ' '], # (1, nil) only blank result
          [1, 'foo', nil, :apple, ' '], # (1, nil) only nil result
        ].freeze
      test_array_data_plain_nil_0 =
        [
          'plain array values',         # description
          [1, 'foo', nil, :apple, ' '], # test data

          [1, 'foo',      :apple, ' '], # non empty result
          [1, 'foo',      :apple     ], # non blank result
          [1, 'foo',      :apple, ' '], # non nil result

          [          nil,            ], # only empty result
          [          nil,         ' '], # only blank result
          [          nil,            ], # only nil result
        ].freeze
      test_array_data_sub1_nil_0 =
        [
          'array values with sub-array elements',                     # description
          [1, 'foo',  '', ' ', nil, [:apple, nil, 'banana', ' ', ''], 'bar'],  # test_data

          [1, 'foo',      ' ',      [:apple, nil, 'banana', ' ', ''], 'bar'],  # non empty result
          [1, 'foo',                [:apple, nil, 'banana', ' ', ''], 'bar'],  # non blank result
          [1, 'foo',  '', ' ',      [:apple, nil, 'banana', ' ', ''], 'bar'],  # non nil result

          [           '',      nil,                                        ],  # only empty result
          [           '', ' ', nil,                                        ],  # only blank result
          [                    nil,                                        ],  # only nil result
        ].freeze
      test_array_data_sub1_1_nil =
        [
          'array values with sub-hash elements',                             # description
          [1, 'foo',  nil, { a: 1, b: nil, c: '', d: 'ok', e: ' ' }, 'bar'], # test data

          [1, 'foo',  nil, { a: 1,                d: 'ok', e: ' ' }, 'bar'], # non empty result
          [1, 'foo',  nil, { a: 1,                d: 'ok'         }, 'bar'], # non blank result
          [1, 'foo',  nil, { a: 1,         c: '', d: 'ok', e: ' ' }, 'bar'], # non nil result

          [1, 'foo',  nil, {       b: nil, c: '',                 }, 'bar'], # only empty result
          [1, 'foo',  nil, {       b: nil, c: '',          e: ' ' }, 'bar'], # only blank result
          [1, 'foo',  nil, {       b: nil,                        }, 'bar'], # only nil result
        ].freeze

      it_behaves_like 'apply_filters_with_args', test_array_data_plain_0_nil, 0, nil
      it_behaves_like 'apply_filters_with_args', test_array_data_plain_1_nil, 1, nil
      it_behaves_like 'apply_filters_with_args', test_array_data_plain_nil_0, nil, 0

      it_behaves_like 'apply_filters_with_args', test_array_data_sub1_nil_0, nil, 0
      it_behaves_like 'apply_filters_with_args', test_array_data_sub1_1_nil, 1, nil
    end

    context 'boolean methods on arrays' do
      test_boolean_array_data =
        [ # data          is_empty?  is_blank?  description
          [ [],           true,      true,      'empty array'],
          [ [nil],        true,      true,      'array with only nils'],
          [ [''],         true,      true,      'array with only empty items'],
          [ ['  ', nil],  false,     true,      'array with non-empty items'],
          [ ['heh', nil], false,     false,     'array with non-blank items'],
          [ ['heh', []],  false,     false,     'array with empty sub-array'],
          [ ['', []],     true,      true,      'empty array with empty sub-array'],
          [ ['', [nil]],  true,      true,      'empty array with nil sub-array'],
          [ ['', ['']],   true,      true,      'empty array with empty string in sub-array'],
          [ ['', [' ']],  false,     true,      'empty array with empty string in sub-array'],
          [ ['', ['x']],  false,     false,     'array with non-empty string in sub-array'],
          [ [nil, [nil]], true,      true,      'array with nil and sub-array nil'],
        ]

      it_behaves_like 'boolean_methods', test_boolean_array_data, :is_empty?, BOOL_IS_EMPTY_INDEX
      it_behaves_like 'boolean_methods', test_boolean_array_data, :is_blank?, BOOL_IS_BLANK_INDEX
    end
  end

  describe "HashFilters" do
    context 'reject and select methods' do
      test_hash_data =
        [
          [
            'hash values',                                  # description
            { a: 1, b: 'foo', c: nil, d: :apple, e: ' ' },  # test data

            { a: 1, b: 'foo',         d: :apple, e: ' ' },  # non empty result
            { a: 1, b: 'foo',         d: :apple },          # non blank result
            { a: 1, b: 'foo',         d: :apple, e: ' ' },  # non nil result

            {                 c: nil,                   },  # only empty values result
            {                 c: nil,            e: ' ' },  # only blank values result
            {                 c: nil,                   },  # only nil values result
          ],
          [
            'hash values with sub-array elements',                       # description
            { a: 1, b: 'foo', c: nil, d: [:apple, nil, ' '], g: 'bar' }, # test data

            { a: 1, b: 'foo',         d: [:apple,      ' '], g: 'bar' }, # non empty result
            { a: 1, b: 'foo',         d: [:apple],           g: 'bar' }, # non blank result
            { a: 1, b: 'foo',         d: [:apple,      ' '], g: 'bar' }, # non nil result

            {                 c: nil, d: [        nil,    ],          }, # only empty result
            {                 c: nil, d: [        nil, ' '],          }, # only blank result
            {                 c: nil,                                 }, # only nil result
          ],
          [
            'hash values with sub-hash elements',                                   # description
            { a: 1, b: 'foo', c: nil, d: { e: :apple, f: nil, g: ' ' }, h: 'bar' }, # test data

            { a: 1, b: 'foo',         d: { e: :apple,         g: ' ' }, h: 'bar' }, # non empty result
            { a: 1, b: 'foo',         d: { e: :apple,                }, h: 'bar' }, # non blank result
            { a: 1, b: 'foo',         d: { e: :apple,         g: ' ' }, h: 'bar' }, # non nil result

            {                 c: nil, d: {            f: nil,        },          }, # only empty result
            {                 c: nil, d: {            f: nil, g: ' ' },          }, # only blank result
            {                 c: nil,                                            }, # only nil result
          ]
        ].freeze

      it_behaves_like 'apply_filter', test_hash_data, :rejects, :reject_empty_values, NON_EMPTY_RESULT_INDEX,  'empty or nil'
      it_behaves_like 'apply_filter', test_hash_data, :rejects, :reject_blank_values, NON_BLANK_RESULT_INDEX,  'blank or nil'
      it_behaves_like 'apply_filter', test_hash_data, :rejects, :reject_nil_values,   NON_NIL_RESULT_INDEX,    'nil'

      it_behaves_like 'apply_filter', test_hash_data, :selects, :only_empty_values,   ONLY_EMPTY_RESULT_INDEX, 'empty or nil'
      it_behaves_like 'apply_filter', test_hash_data, :selects, :only_blank_values,   ONLY_BLANK_RESULT_INDEX, 'blank or nil'
      it_behaves_like 'apply_filter', test_hash_data, :selects, :only_nil_values,     ONLY_NIL_RESULT_INDEX,   'nil'

      it_behaves_like 'filter_values', test_hash_data, :rejects, :is_empty?, NON_EMPTY_RESULT_INDEX,  'empty or nil'
      it_behaves_like 'filter_values', test_hash_data, :rejects, :is_blank?, NON_BLANK_RESULT_INDEX,  'blank or nil'
      it_behaves_like 'filter_values', test_hash_data, :rejects, :nil?,      NON_NIL_RESULT_INDEX,    'nil'

      it_behaves_like 'filter_values', test_hash_data, :selects, :is_empty?, ONLY_EMPTY_RESULT_INDEX, 'empty or nil'
      it_behaves_like 'filter_values', test_hash_data, :selects, :is_blank?, ONLY_BLANK_RESULT_INDEX, 'blank or nil'
      it_behaves_like 'filter_values', test_hash_data, :selects, :is_nil?,   ONLY_NIL_RESULT_INDEX,   'nil'

      it_behaves_like 'key_filters', test_hash_data, :selects, :blank_value_keys,     ONLY_BLANK_RESULT_INDEX, 'blank or nil'
      it_behaves_like 'key_filters', test_hash_data, :selects, :empty_value_keys,     ONLY_EMPTY_RESULT_INDEX, 'empty or nil'
      it_behaves_like 'key_filters', test_hash_data, :selects, :nil_value_keys,       ONLY_NIL_RESULT_INDEX,   'nil'

      it_behaves_like 'key_filters', test_hash_data, :rejects, :non_blank_value_keys, NON_BLANK_RESULT_INDEX, 'blank or nil'
      it_behaves_like 'key_filters', test_hash_data, :rejects, :non_empty_value_keys, NON_EMPTY_RESULT_INDEX, 'empty or nil'
      it_behaves_like 'key_filters', test_hash_data, :rejects, :non_nil_value_keys,   NON_NIL_RESULT_INDEX,   'nil'
    end

    context 'boolean methods on hashes' do
      test_boolean_hash_data =
        [ # data          is_empty?  is_blank?  description
          [ {},           true,      true,      'empty hashes'],
          [ { a: nil },   true,      true,      'nil value hash entry'],
          [ { a: '' },    true,      true,      'empty value hash entry'],
          [ { a: ' ' },   false,     true,      'blank value hash entry'],

          [ [],           true,      true,      'empty arrays'],
          [ [nil],        true,      true,      'arrays with only nils'],
          [ [''],         true,      true,      'arrays with only empty items'],
          [ ['  ', nil],  false,     true,      'arrays with non-empty items'],
          [ ['heh', nil], false,     false,     'arrays with non-blank items'],
        ]

      it_behaves_like 'boolean_methods', test_boolean_hash_data, :is_empty?, BOOL_IS_EMPTY_INDEX
      it_behaves_like 'boolean_methods', test_boolean_hash_data, :is_blank?, BOOL_IS_BLANK_INDEX
    end
  end

  describe "StringFilters" do
    test_string_data =
      [
        # test data     is_empty      is_blank       no_empty_value  no_blank_value  description
        ['',            true,         true,          nil,            nil,            'empty'],
        [' ',           false,        true,          ' ',            nil,            'blank'],
        ['         ',   false,        true,          '         ',    nil,            'all blanks'],
        ["\t",          false,        true,          "\t",           nil,            'tab-only'],
        ["heh",         false,        false,         'heh',          'heh',          'non-blank, non-empty'],
        ["\n\n",        false,        true,          "\n\n",         nil,            'new-lines only'],
        ["heh\n",       false,        false,         "heh\n",        "heh\n",        'non-empty, non-blank with newline']
      ]

    describe "#is_empty?" do
      test_string_data.each do |test_data, is_empty_result, _is_blank_result, _no_empty_value_result, _no_blank_value_result, desc|
        it "returns #{is_empty_result} on #{desc} strings" do
          expect(test_data.is_empty?).to eq is_empty_result
        end
      end
    end

    describe "#is_blank?" do
      test_string_data.each do |test_data, _is_empty_result, is_blank_result, _no_empty_value_result, _no_blank_value_result, desc|
        it "returns #{is_blank_result} on #{desc} strings" do
          expect(test_data.is_blank?).to eq is_blank_result
        end
      end
    end

    describe '#no_empty_value' do
      test_string_data.each do |test_data, _is_empty_result, _is_blank_result, no_empty_value_result, _no_blank_value_result, desc|
        it "returns #{no_empty_value_result} on #{desc} strings" do
          expect(test_data.no_empty_value).to eq no_empty_value_result
        end
      end
    end

    describe '#no_blank_value' do
      test_string_data.each do |test_data, _is_empty_result, _is_blank_result, _no_empty_value_result, no_blank_value_result, desc|
        it "returns #{no_blank_value_result} on #{desc} strings" do
          expect(test_data.no_blank_value).to eq no_blank_value_result
        end
      end
    end
  end

  describe "NilClassFilters" do
    describe "#is_empty?" do
      it "is true" do
        expect(nil.is_empty?).to be true
      end
    end

    describe "#is_blank?" do
      it "is true" do
        expect(nil.is_blank?).to be true
      end
    end
  end

  describe "ObjectFilters" do
    class SomeObjectWithNoLength
    end

    class SomeObjectWithLength
      attr_accessor :length
      def initialize(length: 0)
        @length = length
      end
    end

    class BlankObject < String
      def initialize
        replace(' ')
      end
    end

    class NonBlankObject < String
      def initialize
        replace('xxx')
      end
    end

    obj_w_length   = SomeObjectWithLength.new(length: 5)
    obj_w_zero_len = SomeObjectWithLength.new(length: 0)
    obj_wo_length  = SomeObjectWithNoLength.new
    blank_obj      = BlankObject.new
    non_blank_obj  = NonBlankObject.new
    empty_obj      = obj_w_zero_len
    non_empty_obj  = obj_w_length

    empty_ary          = []
    non_empty_ary      = [4]
    ary_w_some_blanks  = [:a, nil, ' ', [nil], :c]
    ary_w_all_blanks   = ['', nil, '  ', [' '], '    ']

    empty_hash         = {}
    non_empty_hash     = { foo: :bar }
    hash_w_values      = { a: 1, b: 2, c: { d: 3 } }
    hash_w_some_blanks = { a: 1, b: ' ', c: { d: ' ' } }
    hash_w_all_blanks  = { a: '  ', b: '  ', c: { d: '  ' } }

    nil_obj        = nil
    non_nil_obj    = '42'

    shared_examples_for 'object-queries' do |method, object, result|
      context "testing #{method} on #{object}" do
        subject { object.send(method) }
        it { is_expected.to eq result }
      end
    end

    shared_examples_for 'object-filters' do |method, object, result|
      context "testing #{method} on #{object}" do
        subject { object.send(method) }
        it { is_expected.to eq (result ? object : nil) }
      end
    end

    describe '#non_blank' do
      it_behaves_like 'object-filters', :non_blank, blank_obj, false
      it_behaves_like 'object-filters', :non_blank, empty_obj, false
      it_behaves_like 'object-filters', :non_blank, nil_obj,   false

      it_behaves_like 'object-filters', :non_blank, non_blank_obj, true
      it_behaves_like 'object-filters', :non_blank, non_empty_obj, true
      it_behaves_like 'object-filters', :non_blank, non_nil_obj,   true

      it_behaves_like 'object-filters', :non_blank, obj_w_length,   true
      it_behaves_like 'object-filters', :non_blank, obj_wo_length,  true
      it_behaves_like 'object-filters', :non_blank, obj_w_zero_len, false

      it_behaves_like 'object-filters', :non_blank, empty_hash,         false
      it_behaves_like 'object-filters', :non_blank, non_empty_hash,     true
      it_behaves_like 'object-filters', :non_blank, hash_w_values,      true
      it_behaves_like 'object-filters', :non_blank, hash_w_some_blanks, true
      it_behaves_like 'object-filters', :non_blank, hash_w_all_blanks,  false

      it_behaves_like 'object-filters', :non_blank, empty_ary,         false
      it_behaves_like 'object-filters', :non_blank, non_empty_ary,     true
      it_behaves_like 'object-filters', :non_blank, ary_w_some_blanks, true
      it_behaves_like 'object-filters', :non_blank, ary_w_all_blanks,  false
    end

    describe '#non_empty' do
      it_behaves_like 'object-filters', :non_empty, blank_obj, true
      it_behaves_like 'object-filters', :non_empty, empty_obj, false
      it_behaves_like 'object-filters', :non_empty, nil_obj,   false

      it_behaves_like 'object-filters', :non_empty, non_blank_obj, true
      it_behaves_like 'object-filters', :non_empty, non_empty_obj, true
      it_behaves_like 'object-filters', :non_empty, non_nil_obj,   true

      it_behaves_like 'object-filters', :non_empty, obj_w_length,   true
      it_behaves_like 'object-filters', :non_empty, obj_wo_length,  true
      it_behaves_like 'object-filters', :non_empty, obj_w_zero_len, false

      it_behaves_like 'object-filters', :non_empty, empty_hash,         false
      it_behaves_like 'object-filters', :non_empty, non_empty_hash,     true
      it_behaves_like 'object-filters', :non_empty, hash_w_values,      true
      it_behaves_like 'object-filters', :non_empty, hash_w_some_blanks, true
      it_behaves_like 'object-filters', :non_empty, hash_w_all_blanks,  true

      it_behaves_like 'object-filters', :non_empty, empty_ary,         false
      it_behaves_like 'object-filters', :non_empty, non_empty_ary,     true
      it_behaves_like 'object-filters', :non_empty, ary_w_some_blanks, true
      it_behaves_like 'object-filters', :non_empty, ary_w_all_blanks,  true
    end

    describe "#is_empty?" do
      it_behaves_like 'object-queries', :is_empty?, blank_obj, false
      it_behaves_like 'object-queries', :is_empty?, empty_obj, true
      it_behaves_like 'object-queries', :is_empty?, nil_obj,   true

      it_behaves_like 'object-queries', :is_empty?, non_blank_obj, false
      it_behaves_like 'object-queries', :is_empty?, non_empty_obj, false
      it_behaves_like 'object-queries', :is_empty?, non_nil_obj,   false

      it_behaves_like 'object-queries', :is_empty?, obj_w_length,   false
      it_behaves_like 'object-queries', :is_empty?, obj_wo_length,  false
      it_behaves_like 'object-queries', :is_empty?, obj_w_zero_len, true

      it_behaves_like 'object-queries', :is_empty?, empty_hash,         true
      it_behaves_like 'object-queries', :is_empty?, non_empty_hash,     false
      it_behaves_like 'object-queries', :is_empty?, hash_w_values,      false
      it_behaves_like 'object-queries', :is_empty?, hash_w_some_blanks, false
      it_behaves_like 'object-queries', :is_empty?, hash_w_all_blanks,  false

      it_behaves_like 'object-queries', :is_empty?, empty_ary,         true
      it_behaves_like 'object-queries', :is_empty?, non_empty_ary,     false
      it_behaves_like 'object-queries', :is_empty?, ary_w_some_blanks, false
      it_behaves_like 'object-queries', :is_empty?, ary_w_all_blanks,  false
    end

    describe "#is_blank?" do
      it_behaves_like 'object-queries', :is_blank?, blank_obj, true
      it_behaves_like 'object-queries', :is_blank?, empty_obj, true
      it_behaves_like 'object-queries', :is_blank?, nil_obj,   true

      it_behaves_like 'object-queries', :is_blank?, non_blank_obj, false
      it_behaves_like 'object-queries', :is_blank?, non_empty_obj, false
      it_behaves_like 'object-queries', :is_blank?, non_nil_obj,   false

      it_behaves_like 'object-queries', :is_blank?, obj_w_length,   false
      it_behaves_like 'object-queries', :is_blank?, obj_wo_length,  false
      it_behaves_like 'object-queries', :is_blank?, obj_w_zero_len, true

      it_behaves_like 'object-queries', :is_blank?, empty_hash,     true
      it_behaves_like 'object-queries', :is_blank?, non_empty_hash, false
      it_behaves_like 'object-queries', :is_blank?, hash_w_values,      false
      it_behaves_like 'object-queries', :is_blank?, hash_w_some_blanks, false
      it_behaves_like 'object-queries', :is_blank?, hash_w_all_blanks,  true

      it_behaves_like 'object-queries', :is_blank?, empty_ary,         true
      it_behaves_like 'object-queries', :is_blank?, non_empty_ary,     false
      it_behaves_like 'object-queries', :is_blank?, ary_w_some_blanks, false
      it_behaves_like 'object-queries', :is_blank?, ary_w_all_blanks,  true
    end

    describe "#non_blank?" do
      it_behaves_like 'object-queries', :non_blank?, blank_obj, false
      it_behaves_like 'object-queries', :non_blank?, empty_obj, false
      it_behaves_like 'object-queries', :non_blank?, nil_obj,   false

      it_behaves_like 'object-queries', :non_blank?, non_blank_obj, true
      it_behaves_like 'object-queries', :non_blank?, non_empty_obj, true
      it_behaves_like 'object-queries', :non_blank?, non_nil_obj,   true

      it_behaves_like 'object-queries', :non_blank?, obj_w_length,   true
      it_behaves_like 'object-queries', :non_blank?, obj_wo_length,  true
      it_behaves_like 'object-queries', :non_blank?, obj_w_zero_len, false

      it_behaves_like 'object-queries', :non_blank?, empty_hash,         false
      it_behaves_like 'object-queries', :non_blank?, non_empty_hash,     true
      it_behaves_like 'object-queries', :non_blank?, hash_w_values,      true
      it_behaves_like 'object-queries', :non_blank?, hash_w_some_blanks, true
      it_behaves_like 'object-queries', :non_blank?, hash_w_all_blanks,  false

      it_behaves_like 'object-queries', :non_blank?, empty_ary,         false
      it_behaves_like 'object-queries', :non_blank?, non_empty_ary,     true
      it_behaves_like 'object-queries', :non_blank?, ary_w_some_blanks, true
      it_behaves_like 'object-queries', :non_blank?, ary_w_all_blanks,  false
    end

    describe "#non_nil?" do
      it_behaves_like 'object-queries', :non_nil?, blank_obj, true
      it_behaves_like 'object-queries', :non_nil?, empty_obj, true
      it_behaves_like 'object-queries', :non_nil?, nil_obj,   false

      it_behaves_like 'object-queries', :non_nil?, non_blank_obj, true
      it_behaves_like 'object-queries', :non_nil?, non_empty_obj, true
      it_behaves_like 'object-queries', :non_nil?, non_nil_obj,   true

      it_behaves_like 'object-queries', :non_nil?, obj_w_length,   true
      it_behaves_like 'object-queries', :non_nil?, obj_wo_length,  true
      it_behaves_like 'object-queries', :non_nil?, obj_w_zero_len, true

      it_behaves_like 'object-queries', :non_nil?, empty_hash,         true
      it_behaves_like 'object-queries', :non_nil?, non_empty_hash,     true
      it_behaves_like 'object-queries', :non_nil?, hash_w_values,      true
      it_behaves_like 'object-queries', :non_nil?, hash_w_some_blanks, true
      it_behaves_like 'object-queries', :non_nil?, hash_w_all_blanks,  true

      it_behaves_like 'object-queries', :non_nil?, empty_ary,         true
      it_behaves_like 'object-queries', :non_nil?, non_empty_ary,     true
      it_behaves_like 'object-queries', :non_nil?, ary_w_some_blanks, true
      it_behaves_like 'object-queries', :non_nil?, ary_w_all_blanks,  true
    end

    describe '#is_nil?' do
      it_behaves_like 'object-queries', :is_nil?, blank_obj, false
      it_behaves_like 'object-queries', :is_nil?, empty_obj, false
      it_behaves_like 'object-queries', :is_nil?, nil_obj,   true

      it_behaves_like 'object-queries', :is_nil?, non_blank_obj, false
      it_behaves_like 'object-queries', :is_nil?, non_empty_obj, false
      it_behaves_like 'object-queries', :is_nil?, non_nil_obj,   false

      it_behaves_like 'object-queries', :is_nil?, obj_w_length,   false
      it_behaves_like 'object-queries', :is_nil?, obj_wo_length,  false
      it_behaves_like 'object-queries', :is_nil?, obj_w_zero_len, false

      it_behaves_like 'object-queries', :is_nil?, empty_hash,         false
      it_behaves_like 'object-queries', :is_nil?, non_empty_hash,     false
      it_behaves_like 'object-queries', :is_nil?, hash_w_values,      false
      it_behaves_like 'object-queries', :is_nil?, hash_w_some_blanks, false
      it_behaves_like 'object-queries', :is_nil?, hash_w_all_blanks,  false

      it_behaves_like 'object-queries', :is_nil?, empty_ary,         false
      it_behaves_like 'object-queries', :is_nil?, non_empty_ary,     false
      it_behaves_like 'object-queries', :is_nil?, ary_w_some_blanks, false
      it_behaves_like 'object-queries', :is_nil?, ary_w_all_blanks,  false
    end
  end
end
