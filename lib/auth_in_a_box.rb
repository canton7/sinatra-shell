# Adapted from https://gist.github.com/1444494

# Things you need to do before using this lib:
# require 'sinatra/flash' (gem sinatra-flash)
# register Sinatra::Flash
# register Sinatra::AuthInABox
# enable :sessions optionally configuring your favourite sessions settings
# Have a User model, which has the methods self.authenticate(user, pass) and is_admin?
# In your forms (login, signup, etc) make sure you display flash[:errors]

# Sample DataMapper user model
=begin
# From bcrypt-ruby gem
require 'bcrypt'
class User
	include DataMapper::Resource

	attr_accessor :password, :password_confirmation

	property :id, Serial
	property :username, String, :required => true, :length => (2..32), :unique => true
	property :password_hash, String, :length => 60
	property :account_type, Enum[:standard, :admin], :required => true, :default => :standard
	property :active, Boolean, :default => true

	validates_presence_of :password
	validates_presence_of :password_confirmation
  validates_confirmation_of :password

	def self.authenticate(username, pass)
		user = first(:username => username)
		return false unless user && user.active && BCrypt::Password.new(user.password_hash) == pass
		user
	end

	def is_admin?
		account_type == :admin
	end

	def password=(pass)
		@password = pass
		self.password_hash = BCrypt::Password.create(pass).to_s
	end
end
=end


module Sinatra
	module AuthInABox
		def auth_setup(params)
			params.each do |k,v|
				settings.authinabox[k] = v if settings.authinabox.has_key?(k)
			end
		end

		def self.registered(app)
			app.helpers Helpers
			app.set :authinabox, {
				:login_redirect => '/',
				:logout_redirect => '/',
				:signup_redirect => '/',
				:login_url => '/login',
				:account_type => 'account_type',
			}
		end

		module Helpers
			def login(params, options={})
				options = {
					:redirect => true,         # Controls whether we redirect at all
					:success_redirect => nil,  # Override success redirect URL
					:failure_redirect => nil,  # Override failure redirect url
				}.merge(options)
				if user = User.authenticate(params[:username], params[:password])
					session[:user] = user.id
					redirect session[:login_return_to] || options[:success_redirect] || settings.authinabox[:login_redirect] if options[:redirect]
					return user
				else
					flash[:errors] = "Login failed"
					redirect options[:failure_redirect] || request.fullpath if options[:redirect]
					return false
				end
			end

			def logout(options={})
				options = {
					:redirect => true,         # Whether we redirect at all
					:redirect_to => nil,       # Overrides where we redirect to
				}.merge(options)
				session[:user] = nil
				redirect options[:redirect_to] || settings.authinabox[:logout_redirect] if options[:redirect]
			end

			def signup(params, options={})
				options = {
					:login => true,            # Whether we login after creating the account
					:redirect => true,         # Controls whether we redirect at all
					:success_redirect => nil,  # Override where to redirect on success
					:failure_redirect => nil,  # Override where to redirect on failure
				}.merge(options)
				user = User.new(params)
				if user.save
					session[:user] = user.id if options[:login]
					redirect options[:success_redirect] || settings.authinabox[:signup_redirect] if options[:redirect]
					return user
				else
					flash[:errors] = '<ul><li>' << user.errors.full_messages.join('</li><li>') << '</li></ul>'
					redirect options[:failure_redirect] || request.fullpath if options[:redirect]
					return false
				end
			end

			def login_required(options={})
				options = {
					:redirect => true,         # Controls whether we redirect at all
					:login_url => nil,         # Overrides redirect if they aren't authenticated
				}.merge(options)
				return true if session[:user]
				session[:login_return_to] = request.fullpath
				redirect options[:login_url] || settings.authinabox[:login_url] if options[:redirect]
				return false
			end

			def admin_required(options={})
				options = {
					:redirect => true,         # Controls whether we redirect at all
					:login_url => nil,         # Overrides redirect if they aren't authenticated
					:error_msg => 'You need to be an admin', # Flash text to set. False/nil to disable
				}.merge(options)
				unless session[:user]
					session[:login_return_to] = request.fullpath
					redirect options[:login_url] || settings.authinabox[:login_url] if options[:redirect]
					return false
				end
				unless current_user.is_admin?
					flash[:errors] = options[:error_msg] if options[:error_msg]
					session[:login_return_to] = request.fullpath
					redirect options[:login_url] || settings.authinabox[:login_url] if options[:redirect]
					return false
				end
				return true
			end

			def current_user
				return unless session[:user]
				User.get(session[:user])
			end

			def is_admin?
				current_user && current_user.is_admin?
			end

			def is_auth?
				!!session[:user]
			end
		end
	end

	register AuthInABox
end