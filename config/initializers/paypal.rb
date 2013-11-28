# Sandbox ID:APP-80W284485P519543T
# Live App ID:APP-8LY35515XE2348235

# Paypal Sandbox fake accounts

# name:  Buyer McBuyer
# email: buyer_1359858044_per@infinite.ly
# pass:  359857824

# paypalfakebuyer@infinite.ly
# paypal1234

# paypalfakemerchant@infinite.ly
# paypal1234

# name: Seller McSeller
# email: seller_1359858123_biz@infinite.ly
# pass: 359858089

if Rails.env.production? # || Rails.env.staging?

  App.paypal = { url: 'https://www.paypal.com' }

elsif Rails.env.development? || Rails.env.staging?

  App.paypal = { url: 'https://www.sandbox.paypal.com' }

end

App.paypal.email = "helloluis@me.com"