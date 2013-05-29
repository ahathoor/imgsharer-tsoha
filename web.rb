require "sinatra"
require "sinatra/reloader"

require './config/sequel'
require 'haml'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    "hello"
  end

  get '/uploadtest' do
    haml :uploadfile
  end

  post '/uploadtest' do
    unless DB.table_exists?(:pictures)
      DB.create_table :pictures do
        column :name, :text
        column :filename, :text
      end
    end

    filename = 'uploads/' + params[:name]
    picname = params[:name]
    File.open(filename, 'w') do |f|
      f.write(params['myfile'][:tempfile].read)
    end

    pictures = DB[:pictures]
    pictures << {:name => params[:name], :filename => filename}

    pictures.each do |picture|
        p picture
      end
  end

  get '/t3' do
    @name = 'pelle'
    erb :testview, name: @name
  end

  post '/testpost' do
    "what you inputtin \"#{params[:name]}\" fo anyway?"
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
