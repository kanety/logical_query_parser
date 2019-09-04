require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :docs, force: true do |t|
    t.string :title
    t.string :body
    t.timestamps null: false
  end

  create_table :tags, force: true do |t|
    t.references :doc
    t.string :name
  end

  create_table :users, force: true do |t|
    t.references :tag
    t.string :name
  end
end

class Doc < ActiveRecord::Base
  has_many :tags
end

class Tag < ActiveRecord::Base
  has_many :users
end

class User < ActiveRecord::Base
end

def debug(str)
  puts str if ENV['DEBUG'] == '1'
end

def sequence(strs)
  strs.map! { |s| Regexp.escape(s) }
  Regexp.new(strs.join('.*'))
end
