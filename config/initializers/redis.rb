App.redis_config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]

App.redis = Redis.new(App.redis_config)

if Rails.env.production?

  uri = URI.parse("redis://redistogo:ed82059bd102255572cd71c5cc80f41b@grideye.redistogo.com:9483/")
  # uri = URI.parse(ENV["REDISTOGO_URL"])
  
  # ENV['REDISTOGO_URL'] = "redis://redistogo:ed82059bd102255572cd71c5cc80f41b@grideye.redistogo.com:9483/"

  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  App.redis = REDIS

end