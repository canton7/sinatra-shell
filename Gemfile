source 'http://rubygems.org'
gem 'sinatra', :require => 'sinatra/base'
# Several things need eventmachine, but we need to specify the version for windows
gem 'eventmachine', '1.0.0.beta.4.1', :platform => [:mswin, :mingw]
gem 'sinatra-contrib', :require => 'sinatra/contrib'
gem 'thin'
gem 'data_mapper'
gem 'taps', :git => 'git://github.com/canton7/taps.git'
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'
gem 'bcrypt-ruby', :require => 'bcrypt'

group :development, :testing do
  gem 'sqlite3'
  gem 'dm-sqlite-adapter'
end

group :production do
  gem 'mysql'
  gem 'dm-mysql-adapter'
end

