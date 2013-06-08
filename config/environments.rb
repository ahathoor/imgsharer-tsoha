#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
require 'sequel'
configure :production, :development do
	DB = Sequel.connect(ENV['DATABASE_URL'] || ENV['HEROKU_POSTGRESQL_BLUE_URL'])
end
