$:.unshift File.dirname(__FILE__)

require 'config/environment'
require 'models/init'
require 'lib/auth_in_a_box'

class App < Sinatra::Base
	register Sinatra::ConfigFile
	register Sinatra::Namespace
	register Sinatra::Flash
	register Sinatra::AuthInABox

	configure :development do
		use Rack::CommonLogger
		register Sinatra::Reloader
	end

	enable :sessions
	set :erb, :layout => true

end

require 'routes/init'

App.run! if $0 == __FILE__
