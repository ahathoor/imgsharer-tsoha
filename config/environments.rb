#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
require 'sequel'
configure :development do
	DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://postgres:mikko@localhost/mydb')
end
configure :production do
	BD = Sequel.connect('postgres://ovjxtkmbpfhnhk:8MavfeOsUaSHDIb6q3nd0cpLpk@ec2-107-20-217-22.compute-1.amazonaws.com:5432/d6ihc4akhagjv5')
end
