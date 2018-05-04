require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  
  def self.columns
    if @columns.nil?
      columns = DBConnection.execute2("SELECT * FROM #{table_name}")
      @columns = columns.first.map(&:to_sym)
    else
      @columns
    end
  end

  def self.finalize!
    columns.each do |attribute|
      define_method(attribute) do
        attributes[attribute]
      end
      
      define_method("#{attribute}=") do |val|
        attributes[attribute] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name = self.to_s.tableize if @table_name.nil?
    @table_name
  end

  def self.all
    parse_all(DBConnection.execute("SELECT * FROM #{table_name}"))
  end

  def self.parse_all(results)
    all = []
    results.each do |params|
      all << self.new(params)
    end
    all
  end

  def self.find(id)
    result  = DBConnection.execute("SELECT * FROM #{table_name} WHERE id = #{id}")
    # result.nil? ? return nil : 
  end

  def initialize(params = {})
    params.each do |col, val|
      raise "unknown attribute '#{col}'" unless self.class.columns.include?(col.to_sym)
      self.send("#{col}=", val)
    end
    
  end

  def attributes
    @attributes ||  @attributes = {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    cols = self.class.columns.drop(1).map(&:to_s)
    question_marks = ['?'] * cols.length
    col_string, question_mark_string = cols.join(','), question_marks.join(',')
    DBConnection.execute(<<-SQL,*attribute_values.drop(1))
      INSERT INTO
      #{self.class.table_name} (#{col_string})
      VALUES
      (#{question_mark_string}) 
    SQL
    
    self.id = DBConnection.last_insert_row_id
    insert
    
  end
  
  def update
    # ...
  end

  def save
    # ...
  end
end
