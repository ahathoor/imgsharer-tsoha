require "sinatra"
require "sinatra/reloader"

require './config/sequel'
require 'haml'
require 'fileutils'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    enable :sessions
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

  get '/upload' do
    haml :upload
  end

  get '/view_images' do
    haml :view_images
  end

  get '/uploads/:user/:image' do
    File.read("uploads/#{params[:user]}/#{params[:image]}")
  end

  get '/loginregister' do
    haml :loginregister
  end

  get '/mainpage' do
    haml :mainpage
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

  get '/logout' do
    session[:kayttaja] = nil
    redirect '/loginregister'
  end

  post '/login' do
    user = DB[:users].where('username = ?', params[:username])
    p user
    if user.empty?
      return "Username not found!"
    end

    user = DB[:users].where('username = ? and password = ?', params[:username], params[:password])
    if user.empty?
      return "supplied password incorrect!"
    end

    session[:kayttaja] = user.first[:id]
    redirect '/mainpage'
  end

  post '/upload' do
    if !params[:myfile][:type].include? "image"
      return "Not a valid image file"
    end

    path = "uploads/#{kirjautunut_kayttaja[:username]}/#{params[:myfile][:filename]}"
    unless File.directory?(File.dirname(path))
      FileUtils.mkpath(File.dirname(path))
    end

    File.open(path, 'w') do |f|
      f.write(params['myfile'][:tempfile].read)
    end

    pictures = DB[:pictures]
    pictures << {:name => params[:name], :path => path, :owner => session[:kayttaja]}

    plist = ""
    pictures.each do |picture|
        plist += "#{picture}<br>"
    end
    return plist
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

