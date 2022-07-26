require_relative "../config/environment.rb"
require 'active_support/inflector'
#Step 1: Setting Up the Database
class Song
#  Step 2: Building attr_accessors from column names
# The #table_name Method ===================
  def self.table_name
    self.to_s.downcase.pluralize
  end
# The #column_names Method ===================
  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end
# Metaprogramming our attr_accessors ===================
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
# Step 3: Building an abstract #initialize Method ==================
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
#Step 4: Writing our ORM Methods ================
def table_name_for_insert
  self.class.table_name
end
  

def col_names_for_insert
  self.class.column_names.delete_if {|col| col == "id"}.join(", ")
end

def values_for_insert
  values = []
  self.class.column_names.each do |col_name|
    values << "'#{send(col_name)}'" unless send(col_name).nil?
  end
  values.join(", ")
end

# The #save Method:
def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
# Selecting Records in a Dynamic Manner
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



