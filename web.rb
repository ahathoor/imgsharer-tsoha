require "sinatra"
require "sinatra/reloader"

require './config/sequel'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    "hello"
  end

  get '/test' do
    unless DB.table_exists?(:items)
      DB.create_table :items do
        column :name, :text
        column :price, :float
      end
    end

    items = DB[:items]
    items << {:name => 'abc', :price => rand * 100}
    items << {:name => 'def', :price => rand * 100}
    items << {:name => 'ghi', :price => rand * 100}

    puts "Item Count = #{items.count}"

    items.reverse_order(:price).each do |item|
      p item
    end

    puts "The average price is: #{items.avg(:price)}"
  end

end

App.run!
