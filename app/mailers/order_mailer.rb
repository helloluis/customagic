class OrderMailer < ActionMailer::Base

  default from: App.support_email
  
  helper :application

  def send_order_email_to_store_owner user_email, product, order
    headers['X-SMTPAPI'] =  { category: "notification_message",
                                filters: {
                                  click_track: { settings: {'enable' => 1 }},
                                  opentrack: { settings: {'enable' => 1 }},
                                  subscriptiontrack: { settings: {'enable' => 0 }
                                }
                              }
                            }.to_json
    @product = product
    @order = order
    mail( to: user_email,
          subject: "Someone just bought from your store!" )
  end

  def send_order_email_to_admin order
    headers['X-SMTPAPI'] =  { category: "notification_message",
                                filters: {
                                  click_track: { settings: {'enable' => 1 }},
                                  opentrack: { settings: {'enable' => 1 }},
                                  subscriptiontrack: { settings: {'enable' => 0 }
                                }
                              }
                            }.to_json
    @order = order
    mail( to: App.support_email,
          reply_to: order.email,
          subject: "#{order.first_name} #{order.last_name} (#{order.email}) has placed an order in your store!" )
  end

  def send_order_email_to_buyer user_email, order
    headers['X-SMTPAPI'] =  { category: "notification_message",
                                filters: {
                                  click_track: { settings: {'enable' => 1 }},
                                  opentrack: { settings: {'enable' => 1 }},
                                  subscriptiontrack: { settings: {'enable' => 0 }
                                }
                              }
                            }.to_json
    @order = order
    mail( to: user_email,
          subject: "#{App.name}: Your order has been received!" )
  end

  def send_processing_notice_to_buyer(order, site)
    @recipient_email = order.email
    @order = order
    mail( to: @recipient_email,
          subject: "#{App.name}: We've begun processing your order!" )
  end

  def send_message_to_buyer(order, site, msg)
    @recipient_email = order.email
    @order = order
    @message = msg
    mail( to: @recipient_email,
          subject: "Hello from #{App.name}" )
  end

  def send_shipping_notice_to_buyer(order, site)
    @recipient_email = order.email
    @order = order
    mail( to: @recipient_email,
          subject: "#{App.name}: We've shipped your order!" )
  end

  def send_fulfillment_notice_to_buyer(order,site)
    @recipient_email = order.email
    @order = order
    mail( to: @recipient_email,
          subject: "#{App.name}: Your order has been fulfilled and/or shipped!" )
  end

  def send_cancellation_notice_to_buyer(order,site)
    @recipient_email = order.email
    @order = order
    mail( to: @recipient_email,
          subject: "#{App.name}: Your order has been cancelled!" )
  end

  def send_cancellation_notice_to_seller(order,site)
    @recipient_email = site.account.creator.email
    @order = order
    mail( to: @recipient_email,
          reply_to: order.email,
          subject: "#{App.name}: A buyer (#{order.email}) has cancelled their order!" )
  end

  def send_rejection_notice_to_buyer(order,site)
    @recipient_email = order.email
    @order = order
    mail( to: @recipient_email,
          subject: "#{App.name}: Your order has been rejected!" )
  end

  def send_rejection_notice_to_seller(order,site)
    @recipient_email = order.shop.site.creator.email
    @order = order
    mail( to: @recipient_email,
          subject: "#{App.name}: The order from #{order.email} has been rejected!" )
  end

  def send_failed_order_notification(cart, order, paypal_opts)
    @cart = cart
    @order = order
    @contents = order.contents
    @paypal_opts = paypal_opts
    @errors = order.errors
    @shop = order.shop
    mail( to: App.support_email,
          subject: "#{App.name}: Order Failure" )
  end

end