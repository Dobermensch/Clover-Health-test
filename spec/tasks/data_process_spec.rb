require 'rails_helper'
require 'rake'

RSpec.describe Rake::Task do
    Rails.application.load_tasks

    context 'data_process' do
        it 'should create a new migration file and run it' do
            num_migration_files = Dir[Rails.root.join('db/migrate/*')].length
            Rake::Task["data_process:table_create"].invoke('testformat2')
            expect(Dir[Rails.root.join('db/migrate/*')].length).to eq(num_migration_files + 1)

            timestamp = Dir[Rails.root.join('db/migrate/*')].last.split("/").last.split("_").first

            query = "select version from schema_migrations where version = '%s'" % [timestamp]
            ran_migration = ActiveRecord::Base.connection.execute(query).any?
            expect(ran_migration).to be_truthy

            `rails db:rollback VERSION=#{timestamp}`
            `rails d model Testformat2`
        end
        
        it 'should insert data into the database in the correct table' do
            Rake::Task["data_process:import_data"].invoke("testformat1_2015-06-28")

            num = Testformat1.all.count
            
            expect(num).to eq(3)
        end
    end
end