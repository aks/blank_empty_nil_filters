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

    let(:obj_with_length)    { SomeObjectWithLength.new(length: 5) }
    let(:obj_without_length) { SomeObjectWithNoLength.new }

    describe "#is_empty?" do
      subject { test_obj.is_empty? }

      context 'when it responds to .length' do
        context 'when the length is zero' do
          let(:test_obj) { SomeObjectWithLength.new(length: 0) }
          it { is_expected.to be true }
        end

        context 'when the length is non-zero' do
          let(:test_obj) { SomeObjectWithLength.new(length: 10) }
          it { is_expected.to be false }
        end
      end

      context 'when it does not respond to length' do
        let(:test_obj) { SomeObjectWithNoLength.new }
        it { is_expected.to be false }
      end
    end

    describe "#is_blank?" do
      subject { test_obj.is_blank? }

      context 'when it responds to .length' do
        context 'when the length is zero' do
          let(:test_obj) { SomeObjectWithLength.new(length: 0) }
          it { is_expected.to be true }
        end

        context 'when the length is non-zero' do
          let(:test_obj) { SomeObjectWithLength.new(length: 10) }
          it { is_expected.to be false }
        end
      end

      context 'when it does not respond to length' do
        let(:test_obj) { SomeObjectWithNoLength.new }
        it { is_expected.to be false }
      end
    end

    describe "#non_blank?" do
      subject { test_obj.non_blank? }

      context 'with a string' do
        context "with a non-blank string" do
          let(:test_obj) { +'foobar' }
          it { is_expected.to be true }
        end

        context 'with a blank string' do
          let(:test_obj) { +'' }
          it { is_expected.to be false }
        end
      end

      context "with a hash" do
        context 'with a hash with no blank values' do
          let(:test_obj) { { a: 1, b: 2, c: { d: 3 } } }
          it { is_expected.to be true }
        end

        context 'with a hash with some blank values' do
          let(:test_obj) { { a: 1, b: ' ', c: { d: ' ' } } }
          it { is_expected.to be true }
        end

        context 'with a hash with all blank values' do
          let(:test_obj) { { a: '  ', b: '  ', c: { d: '  ' } } }
          it { is_expected.to be false }
        end
      end

      context 'with an array' do
        context 'with an array with no blank values' do
          let(:test_obj) { [:a, 2, 'c'] }
          it { is_expected.to be true }
        end

        context 'with an array with some blank values' do
          let(:test_obj) { [:a, 2, [:c, ' ', nil]] }
          it { is_expected.to be true }
        end

        context 'with an array with all blank values' do
          let(:test_obj) { [nil, ' ', [' ', nil]] }
          it { is_expected.to be false }
        end
      end
    end

    describe "#non_nil?" do
      subject { test_obj.non_nil? }

      context "with a nil" do
        let(:test_obj) { nil }

        it { is_expected.to be false }
      end

      context "with a non-nil" do
        let(:test_obj) { 'foobar' }
        it { is_expected.to be true }
      end
    end
  end
end
