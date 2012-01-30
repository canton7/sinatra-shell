$:.unshift File.dirname(__FILE__)

require 'config/environment'

namespace :db do
	require 'models/init'

	desc "Auto-upgrade the database"
	task :upgrade do
		DataMapper.auto_upgrade!
	end

	desc "Auto-migrate the database. DESTRUCTIVE"
	task :migrate do
		DataMapper.auto_migrate!
	end
end

namespace :taps do
	task :server do
		# taps doesn't like 'sqlite3' databases :(
		db = ENV['DM_DB'].sub('sqlite3', 'sqlite')
		sh "taps server #{db} #{ENV['user'] || 'user'} #{ENV['pass'] | 'pass'} -p #{ENV['port'] || 5000}"
	end
end