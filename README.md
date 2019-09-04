# LogicalQueryParser

A parser to generate a tree structure from a logical search query string using treetop.

## Dependencies

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

# return value is a syntax tree of treetop
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
parser.parse('("a a" AND NOT "b b") OR (c AND -d)')
```

### Supported operators

* AND / and / &: represents an AND logic.
* OR / or / |: represents an OR logic.
* NOT / \-: represents a NOT logic. This should precede to a word or a parenthesis.
* (: represents beginning of a nested expression.
* ): represents end of a nested expression.
* ": represents beginning or end of a quoted word.
* Space: represents a boundary between two words.

For more information, see [grammar definition](lib/logical_query_parser.treetop).

### Use with ActiveRecord

You can use a syntax tree to compile a SQL statement for activerecord. For example:

```ruby
class Doc < ActiveRecord::Base
end

LogicalQueryParser.search("a AND b", Doc.all, :c1, :c2).to_sql
# SELECT "docs".* FROM "docs"
#  WHERE (("docs"."c1" LIKE '%a%' OR "docs"."c2" LIKE '%a%') AND ("docs"."c1" LIKE '%b%' OR "docs"."c2" LIKE '%b%'))
```

Use with associations:

```ruby
class Doc < ActiveRecord::Base
  has_many :tags
end

class Tag < ActiveRecord::Base
end

LogicalQueryParser.search("a AND b", Doc.all, :c1, :c2, tags: [:c3]).to_sql
# SELECT "docs".* FROM "docs"
#  INNER JOIN "tags" ON "tags"."doc_id" = "docs"."id"
#  WHERE ((("docs"."c1" LIKE '%a%' OR "docs"."c2" LIKE '%a%') OR "tags"."c3" LIKE '%a%') AND
#        (("docs"."c1" LIKE '%b%' OR "docs"."c2" LIKE '%b%') OR "tags"."c3" LIKE '%b%'))
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kanety/logical_query_parser.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

