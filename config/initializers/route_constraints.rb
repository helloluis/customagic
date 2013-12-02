Rails.application.config.action_dispatch.tld_length = App.tld_length

module RouteConstraints

  class HasAccount
    def self.matches?(request)
      request.env['warden'].authenticate?(scope: :user) and not request.env['warden'].user(:user).primary_account.nil?
    end
  end

  class NoAccount
    def self.matches?(request)
      request.env['warden'].authenticate?(scope: :user) and request.env['warden'].user(:user).primary_account.nil?
    end
  end

  module Subdomain
    class Base
      def self.subdomain(request)
        request.subdomain(App.tld_length)
      end
    end

    class None < Base
      def self.matches?(request)
        subdomain(request).blank? or %(www m).include?(subdomain(request))
      end
    end

    class Site < Base
      def self.matches?(request)
        !subdomain(request).nil? and !%(www admin m).include?(subdomain(request))
      end
    end

    class Admin < Base
      def self.matches?(request)
        subdomain(request) == "admin"
      end
    end
  end
end