require 'csv'

namespace :data_process do
  desc "Creates a table from the given spec file"
  task :table_create, [:filename] do |t, args|
    filename = args.filename.to_s
    cap_filename = filename.capitalize

    command = "rails g model #{cap_filename} "
    
    CSV.parse(File.read("specs/#{filename}.csv"), headers: true).each do |row|
      type = case row[2]
        when "TEXT" then "string"
        when "BOOLEAN" then "boolean"
        when "INTEGER" then "integer"
        else "string"
      end
      
      count = row[1]

      name = row[0]

      if type == "boolean"
        command += "#{name}:#{type} "
      else
        command += "#{name}:#{type}{#{count}} "
      end
    end
    
    command += "--no-timestamps"

    # executes command to create migration
    Rake.sh command

    # executes migration and creates table
    `rails db:migrate`
  end

  desc "Imports data to a table depending on the filename"
  task :import_data, [:filename] do |t, args|
    filename = args.filename.to_s

    file_format = filename.split("_").first

    ff = CSV.parse(File.read("specs/#{file_format}.csv"), headers: true)
    
    names = ff.by_col[0] # assumes column name is always first column
    
    data = []

    File.foreach("data/#{filename}.txt") do |line|
      l = line.split(" ")
      
      name = l.first
      bool = l[1][0] # first char of second element in l
      number = nil

      if l.length == 3 
        number = l.last
      elsif l.length == 2
        number = l[1][1..-1]
      end

      number = number.to_i

      obj = {}
      line_data = [name, bool, number]

      names.map.with_index {|n, i| obj[n] = line_data[i]}
      data.push(obj)
    end

    data.each do |o|
      vals = names.map{|n| o[n]}
      processed = []

      vals.each do |v|
        if v.is_a? Integer
          processed.push(v)
        else
          processed.push("'" + v + "'")
        end
      end

      query = "insert into #{file_format}s (#{names.join(',')}) values (#{processed.join(',')})"
      ActiveRecord::Base.connection.execute(query)
    end
  end
end
