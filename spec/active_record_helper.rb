require 'active_record'

ActiveRecord::Base.establish_connection(
  ENV.fetch('DATABASE_URL') { { adapter: 'sqlite3', database: ':memory:' } }
)

json_column_type = case ActiveRecord::Base.connection.adapter_name
                   when 'PostgreSQL', 'PostGIS' then :jsonb
                   when 'Mysql2', 'Trilogy' then :json
                   else :text
                   end

connection = ActiveRecord::Base.connection

connection.create_table :docs, temporary: true do |t|
  t.string :title
  t.string :body
  t.integer :rank
  t.column :data, json_column_type
  t.timestamps null: false
end

connection.create_table :tags, temporary: true do |t|
  t.references :doc
  t.string :name
  t.column :data, json_column_type
end

connection.create_table :flags, temporary: true do |t|
  t.references :doc
  t.string :name
end

connection.create_table :users, temporary: true do |t|
  t.references :tag
  t.string :name
end

class Doc < ActiveRecord::Base
  has_many :tags
  has_many :flags
end

class Tag < ActiveRecord::Base
  has_many :users
  belongs_to :doc
end

class Flag < ActiveRecord::Base
  has_many :tags
  belongs_to :doc
end

class User < ActiveRecord::Base
end

def debug(str)
  puts str if ENV['DEBUG'] == '1'
end

def sequence(strs)
  strs.map! do |s|
    Regexp.escape(s)
  end
  Regexp.new(strs.join('[^()]*'))
end
