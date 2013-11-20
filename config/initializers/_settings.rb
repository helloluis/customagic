require 'ostruct'

settings = YAML.load_file Rails.root.join("config/settings/environments/#{Rails.env}.yml")
Dir[Rails.root.join("config/settings/*.yml")].each do |file|
  settings.merge!({ File.basename(file, '.yml') => YAML.load_file(file)[Rails.env] })
end

App = Hashie::Mash.new(settings)

