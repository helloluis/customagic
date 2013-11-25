# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :mongoid_store

# Rails.application.config.session_store :active_record_store

# if Rails.env.production?
#   Rails.application.config.session_store :redis_store,
#     key: "_customagic_session",
#     domain: :all,
#     servers: {
#      # redis://rediscloud:kdUx4MqsHttMNdW9@pub-redis-19687.us-east-1-2.1.ec2.garantiadata.com:19687
#       host: 'pub-redis-19687.us-east-1-2.1.ec2.garantiadata.com',
#       password: 'kdUx4MqsHttMNdW9',
#       port: 19687
#     }
# else 

# Rails.application.config.session_store :redis_store, key: '_customagic_session', servers: App.redis

Rails.application.config.session_store :mongoid_store, key: '_customagic_session', collection: lambda { Mongoid.default_session[:sessions] }

#end