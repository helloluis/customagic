# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :mongoid_store

# Rails.application.config.session_store :active_record_store

if Rails.env.production?
  Rails.application.config.session_store :redis_store,
    key: "_customagic_session",
    domain: :all,
    servers: {
      host: 'grideye.redistogo.com',
      password: 'ed82059bd102255572cd71c5cc80f41b',
      port: 6379
    }
else 

  Rails.application.config.session_store :redis_store, key: '_customagic_session', servers: App.redis.id

end