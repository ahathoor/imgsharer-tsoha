#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
require 'sequel'
configure :production, :development do
	DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://ovjxtkmbpfhnhk:8MavfeOsUaSHDIb6q3nd0cpLpk@ec2-107-20-217-22.compute-1.amazonaws.com/d6ihc4akhagjv5')
end
