
# if Rails.env.production?

#   uri = URI.parse("redis://redistogo:ed82059bd102255572cd71c5cc80f41b@grideye.redistogo.com:9483/")
  
#   App.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
#   # App.redis = REDIS

# else

# App.redis_config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]

# uri = URI.parse("redis://redistogo:ed82059bd102255572cd71c5cc80f41b@grideye.redistogo.com:9483/")
# App.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
# App.redis = Redis.new(App.redis_config)


#end


# unless Rails.env.production?

#   App.redis_config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
#   App.redis = Redis.new(App.redis_config)

# else
  
#   uri = URI.parse("redis://rediscloud:kdUx4MqsHttMNdW9@pub-redis-19687.us-east-1-2.1.ec2.garantiadata.com:19687")
#   App.redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)

# end