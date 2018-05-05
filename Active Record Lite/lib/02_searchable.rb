require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    cols = params.keys.map { |col| "#{col} = ?"}
    vals = params.values
    
    search_str = cols.join(" AND ") 
    
    selected = DBConnection.execute(<<-SQL, *vals)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{search_str}
    SQL
    
    selected.map { |item| self.new(item) }
  end
end

class SQLObject
  extend Searchable
end
