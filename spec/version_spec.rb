# frozen_string_literals: true

require 'spec_helper'
require 'blank_empty_nil_filters'

RSpec.describe 'BlankEmptyNilFilters::VERSION' do
  it 'has a RELEASES array' do
    expect(defined?(BlankEmptyNilFilters::RELEASES)).to eq 'constant'
    expect(BlankEmptyNilFilters::RELEASES).to be_an(Array)
  end

  it 'has a VERSION constant' do
    expect(defined?(BlankEmptyNilFilters::VERSION)).to eq 'constant'
  end

  it 'has a semvar version string' do
    expect(BlankEmptyNilFilters::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end
end
