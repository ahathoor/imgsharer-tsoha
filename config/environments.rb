#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
require 'sequel'
configure :production, :development do
	DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://postgres:mikko@localhost/mydb')
	db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
 
	ActiveRecord::Base.establish_connection(
			:adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
			:host     => db.host,
			:username => db.user,
			:password => db.password,
			:database => db.path[1..-1],
			:encoding => 'utf8'
	)
end
