# Testa

simple test framework

## Installation

Add this line to your application's Gemfile:

    gem 'testa'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install testa

## Usage

### create tests

```ruby
require 'testa'
include Testa

test("some description") {
  ok { true }
  /* test code goes here */
}
```

### assertion

- `ok(&block)`
- `error(class_or_message=nil, message=nil, &block)`

### run test

`Testa.run!`

