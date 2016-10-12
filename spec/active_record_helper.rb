require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :docs, force: true do |t|
    t.string :title
    t.string :body
    t.timestamps null: false
  end
end

class Doc < ActiveRecord::Base
end
