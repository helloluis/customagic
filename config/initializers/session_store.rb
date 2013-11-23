# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :mongoid_store

# Rails.application.config.session_store :active_record_store

unless Rails.env.production?
  Rails.application.config.session_store :redis_store, key: '_customagic_session', servers: App.redis.id
else
  Rails.application.config.session_store :redis_store, key: '_customagic_session', domain: :all, servers: App.redis.id
end
