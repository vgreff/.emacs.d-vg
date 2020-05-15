#######################################################################
## Copyright (c) by Daniel Davidson                                    
## All Rights Reserved.                                                
#######################################################################
require 'rubygems'
require 'sequel'

class Sequel::Dataset
  require 'terminal-table/import'
  def to_ascii_table(options = { })
    ascii_table = table do |t|
      self.each do |row|
        new_row = []
        columns.each do |column| 
          value = row[column].to_s
          if (col_opts = options[column])
            if (max_size = col_opts[:max_size])
              if value.length > max_size
                value = value[0, max_size]
                value[-3,3] = '...'
              end
            end
          end
          new_row << value.gsub("\n", '\\n')
        end
        t.add_row new_row
      end
      t.headings = columns
    end
    if ascii_table.rows.length > 0
      ascii_table      
    else
      nil
    end

  end
end
