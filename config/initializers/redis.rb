App.redis_config = YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]

App.redis = Redis.new(App.redis_config)

# Cashier::Adapters::RedisStore.redis = App.redis
