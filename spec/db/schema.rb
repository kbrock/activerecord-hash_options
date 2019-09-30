# encoding: UTF-8

ActiveRecord::Schema.define(:version => 0) do
  self.verbose = false

  create_table :table1s, :force => true do |t|
    t.string  :name
    t.integer :value, :null => true
  end
end
