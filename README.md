# LogicalQueryParser

A parser to generate a tree structure from a logical search query string using treetop.

## Requirements

* ruby 2.3+
* treetop 1.6+
* activerecord 4.2+ (optional)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'logical_query_parser'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logical_query_parser

## Usage

You can parse a logical query string as follows:

```ruby
parser = LogicalQueryParser.new
parser.parse('a AND b')
```

Return value is a syntax tree of treetop:

```ruby
parser = LogicalQueryParser.new
parser.parse('a AND b')

=> SyntaxNode+Exp0+ExpNode offset=0, "a AND b" (any):
  SyntaxNode+Cond0+CondNode offset=0, "a AND b" (lexp,logic,rexp):
    SyntaxNode+Literal0+LiteralNode offset=0, "a" (word,negative):
      SyntaxNode offset=0, ""
      SyntaxNode+WordNode offset=0, "a":
        SyntaxNode+Atom0 offset=0, "a":
          SyntaxNode offset=0, ""
          SyntaxNode offset=0, "a"
    SyntaxNode offset=1, " ":
      SyntaxNode offset=1, " "
    SyntaxNode+AndNode offset=2, "AND"
    SyntaxNode offset=5, " ":
      SyntaxNode offset=5, " "
    SyntaxNode+Exp0+ExpNode offset=6, "b" (any):
      SyntaxNode+Literal0+LiteralNode offset=6, "b" (word,negative):
        SyntaxNode offset=6, ""
        SyntaxNode+WordNode offset=6, "b":
          SyntaxNode+Atom0 offset=6, "b":
            SyntaxNode offset=6, ""
            SyntaxNode offset=6, "b"
```

You can parse quoted strings:

```
parser = LogicalQueryParser.new
parser.parse('("a a" AND "b b") OR (c AND d)')
```

You can also parse negative conditions:

```
parser = LogicalQueryParser.new
parser.parse('("a a" AND -"b b") OR (c AND -d)')
```

### Supported operators

You can parse a query string with following operators:

* AND / and: represents an AND logic.
* OR / or: represents an OR logic.
* \-: represents a NOT logic. This should precede to a word.
* (: represents beginning of a nested expression.
* ): represents end of a nested expression.
* ": represents beginning or end of a quoted word.
* Space: represents a boundary between two words.

For more information, see [grammar definition](lib/logical_query.treetop).

### Compile into SQL

You can compile a syntax tree into a SQL statement by using activerecord model. For example, the code below

```ruby
class Table < ActiveRecord::Base
  def build_sql(str = "a AND b")
    parser = LogicalQueryParser.new
    parser.parse(str).to_sql(model: self, columns: %w(c1 c2))
  end
end
```

builds a SQL statement as follows (this example shows a postgresql statement):

```sql
("tables"."c1" ILIKE '%a%' OR "tables"."c2" ILIKE '%a%') AND ("tables"."c1" ILIKE '%b%' OR "tables"."c2" ILIKE '%b%')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kanety/logical_query_parser. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

