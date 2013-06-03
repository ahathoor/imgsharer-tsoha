require "sinatra"
require "sinatra/reloader"

require './config/sequel'
require 'haml'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    def kirjautunut?
      !session[:kayttaja].nil?
    end

    def kirjautunut_kayttaja
      DB.fetch("SELECT id, username FROM users WHERE id = ?", session[:kayttaja]).first
    end
  end

  before do
    unless kirjautunut? or request.path_info =~ /^\/loginregister/ or request.path_info =~ /^\/login/ or request.path_info =~ /^\/register/
      redirect '/loginregister'
    end
  end

  get '/uploadtest' do
    haml :uploadfile
  end

  get '/loginregister' do
    haml :loginregister
  end

  post '/register' do
    username = params[:username]
    password = params[:password]
    users = DB[:users]
    if !DB[:users].where(:username => username).empty?
      return "error, username already exists"
    else
      users << {:username => username, :password => password}
      "Successfully added user " + username +  " <br>with password " + password
    end
  end

  post '/login' do
    ret = "Available users and passwords: <br>"
    for user in DB[:users] do
       ret += user[:username] + ":" + user[:password] + "<br>"
    end

    user = DB[:users].where('username = ?', params[:username])
    p user
    if user.empty?
      return ret + "Username not found!"
    end

    user = DB[:users].where('username = ? and password = ?', params[:username], params[:password])
    if user.empty?
      return ret + "supplied password incorrect!"
    end

    session[:kayttaja] = user.first[:id]

    return ret + "Successfully logged in."
  end

  post '/uploadtest' do

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

end

def initDB

  unless DB.table_exists?(:users)
    DB.create_table :users do
      primary_key :id
      String :username, :unique => true
      String :password
    end
  end

  unless DB.table_exists?(:pictures)
    DB.create_table :pictures do
      primary_key :id
      String :name
      String :path
      foreign_key :owner, :users
      TrueClass :public, :default => true
    end
  end

  unless DB.table_exists?(:categorizations)
    DB.create_table :categorizations do
      primary_key :id
      String :category_name
      foreign_key :picture_id, :pictures
    end
  end

  unless DB.table_exists?(:comments)
    DB.create_table :comments do
      primary_key :id
      String :text
      foreign_key :commenter, :users
      foreign_key :picture_id, :pictures
    end
  end
end

initDB
App.run!

