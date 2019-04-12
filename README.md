# blank_empty_nil_filters

Ruby gem to extend Hash and Array with filters for blank, empty, and nil values.

Build status: [![CircleCI](https://circleci.com/gh/aks/blank_empty_nil_filters/tree/master.svg?style=svg)](https://circleci.com/gh/aks/blank_empty_nil_filters/tree/master)

This module creates new methods to be prepended to the Array, Hash, String,
and Object classes to implement recursive filters for _blank_, _empty_, and
nil values.

Note: `ActiveSupport` provides _some_ of these methods, but in general is a *much* larger body
of code.  This module are only those methods related to "blank", "empty" or nil. Also,
`ActiveSupport` uses `Regexp` `match` to determine blankness, while this code uses a
non-destructive `strip`, which is both faster and less sensitive to non-UTF8 string error
conditions.

In general an _empty_ value has zero length, and a _blank_ value is either empty or has
all blank values (e.g., `to_s.strip.length.zero?`)

In the descriptions below, `aoh` is an `Array` or `Hash` object.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'blank_empty_nil_filters'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blank_empty_nil_filters

## Usage:

```ruby
require 'blank_empty_nil_filters'

hash.no_empty_values        # exclude key/value pairs where the value is empty
array.no_blank_values       # the array without blank values (or sub-values)

hash.non_blank_value_keys   # keys associated with non-blank values
hash.blank_value_keys       # keys associated with blank values

obj.is_empty?               # true if the object is nil or has length == 0
obj.is_blank?               # true if the object is nil, empty or all whitespace
```

These are _recursive_ filters: nested arrays or hashes are processed automatically

```ruby
aoh.no_empty_values         # items without zero-sized values
aoh.no_blank_values         # items without zero-sized or blank values
aoh.no_nil_values           # items without nil values (a recursive .compact)

hash.only_empty_values      # hash items with only empty values
hash.only_blank_values      # hash items with only blank values
hash.only_nil_values        # hash items with only nil values

hash.empty_value_keys       # keys from empty values
hash.blank_value_keys       # keys from blank values
hash.nil_value_keys         # keys from nil values
```

All of the `no_*` methods have aliases of `reject_*`.  For example, `reject_empty_values`.
Some folks prefer the shorter names, some prefer the longer ones.  Take your pick.

```ruby
aoh.reject_empty_values     # aoh.no_empty_values
aoh.reject_blank_values     # aoh.no_blank_values
aoh.reject_nil_values       # aoh.no_nil_values
```

All of the above methods are wrappers around two general purpose methods:

```ruby
aoh.reject_values(:condition_method)  # reject items matching :condition_method
aoh.select_values(:condition_method)  # select items matching :condition_method
```


The methods below are used with the general purpose methods to form the special-case filters.

```ruby
obj.is_empty?      # true if object is nil or has zero size
obj.is_blank?      # true if object is nil, has zero size or is blank (whitespace strings)
obj.is_nil?        # object.nil?

obj.non_empty?     # true if object is not nil and has non-zero size
obj.non_blank?     # true if object is not nil and has non-zero size, and is not blank
obj.non_nil?       # !object.nil?
```

For _hash_ or _array_ objects, `is_empty?` and `is_blank?` work recursively on the object
elements, and the result is true only if true at every level.

There are also convenience methods to select the keys from filtered hash items:

```ruby
hash.nil_value_keys       => hash.only_nil_values.keys
hash.empty_value_keys     => hash.only_empty_values.keys
hash.blank_value_keys     => hash.only_blank_values.keys

hash.non_nil_value_keys   => hash.no_nil_values.keys
hash.non_empty_value_keys => hash.no_empty_values.keys
hash.non_blank_value_keys => hash.no_blank_values.keys
```

## Examples:

### Hash Filters

The most common usage of `no_empty_values` is with hashes of parameters, which are formed from
many variables, and then the empty or blank ones can be easily filtered out of the hash:

```ruby
{ 'Input' => {
    'Path'      => params[:path],
    'Workspace' => params[:workspace],
    'Source'    => params[:source],
  },
  'Output' => {
    'Type'    => params[:type],
    'Headers' => params[:headers],
  }
}.no_empty_values
```

With `params` containing:

```ruby
params = { source: 'source-content', type: :pdf }
```

The `no_empty_values` would yield the following hash:

```ruby
{ 'Input'  => { 'Source' => "source-content" }, 'Output' => { 'Type'   => :pdf } }
```

If the `params` hash were missing both `:type` and `:headers`, the result would be:

```ruby
{ 'Input'  => { 'Source' => "source-content" } }
```

Another example:

```ruby
params = { file: '   ', type: :pdf, pattern: nil, dest: ''}
params.no_nil_values   => { file: '   ', type: :pdf, dest: '' }
params.no_empty_values => { file: '   ', type: :pdf }
params.no_blank_values => { type: :pdf }
```

#### Finding keys with empty values

Sometimes, it's not the key-value pairs that are non-empty that are desired; instead,
the programmer often wants the keys with empty, blank, or nil values, _(e.g., so they can 
be reported on)_.

```ruby
params = { file: '   ', type: :pdf, pattern: nil, dest: ''}
params.nil_value_keys   => [:pattern]
params.empty_value_keys => [:pattern, :dest]
params.blank_value_keys => [:file, :pattern, :dest]
```

### Array Filters

To filter out empty (zero-length) values from an array:

```ruby
[:1 '' nil :2].no_empty_values => [:1 :2]

[:1 ['' :b] nil :2 ['' '']].no_empty_values => [:1 [:b] :2]
```

Note that the filter is recursive, and if a sub-array is entirely empty, it is filtered out also _(because it also has zero length, after its items have been filtered)_.

The `nil` is considered an "empty" value.

To filter out _blank_ values from an array:

```ruby
[:1 " " "    " nil ['' '    '] :2].no_blank_values => [:1 :2]
```

## Testing

There is an `rspec`-style test in the `spec` directory, the perusal of which will also provide
some examples of usage.

The rspec-style tests are normally run under the `fuubar` formatter gem which shows an incremental summary on a single line.  The
tests can be run with `rake` or with `rspec`:

    bundle exec rake spec

or

    bundle exec rspec

However, if you wish to see all of the usual "documentation" style output, use the `-f doc` option on the `rspec` invocation:

    bundle exec rspec -f doc

## Development

After checking out the repo, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aks/blank_empty_nil_filters

## Author

Alan K. Stebbens <aks@stebbens.org>

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
