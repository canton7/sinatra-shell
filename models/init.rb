
config = YAML.load(ERB.new(File.read(File.expand_path(File.join(File.dirname(__FILE__), '../config/database.yml')))).result)

if config.has_key?(ENV['RACK_ENV'])
	config = config[ENV['RACK_ENV']]
elsif config.has_key?(ENV['RACK_ENV'].to_s)
	config = config[ENV['RACK_ENV'].to_s]
end

ENV['DM_LOG_LEVEL'] ||= config['log_level'].to_s || 'warn'
ENV['DM_DB'] ||= config['db']

# Add CWD to sqlite path
if ENV['DM_DB'] =~ %r{^(sqlite3?://)(.*)}
	ENV['DM_DB'] = "#{$1}#{Dir.pwd}/#{$2}"
end

DataMapper::Logger.new($stdout, ENV['DM_LOG_LEVEL'])
DataMapper.setup(:default, ENV['DM_DB'])
DataMapper.finalize
DataMapper.auto_upgrade!