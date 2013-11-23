module AuthenticationFields
  extend ActiveSupport::Concern

  included do

    # devise fields
    field :encrypted_password,      :type => String, :default => ""
    field :password_changed_at,     :type => Time
    field :reset_password_token,    :type => String
    field :reset_password_sent_at,  :type => Time
    field :remember_created_at,     :type => Time
    
    field :sign_in_count,           :type => Integer, :default => 0
    field :current_sign_in_at,      :type => Time
    field :last_sign_in_at,         :type => Time
    field :current_sign_in_ip,      :type => String
    field :last_sign_in_ip,         :type => String
    
    field :password_salt,           :type => String
    
    field :confirmation_token,      :type => String
    field :confirmed_at,            :type => Time
    field :confirmation_sent_at,    :type => Time
    field :unconfirmed_email,       :type => String # Only if using reconfirmable
    
    field :deactivated,             :type => Boolean, :default => false
    field :status,                  :type => String,  :default => 'pending'
    field :failed_attempts,         :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
    field :unlock_token,            :type => String # Only if unlock strategy is :email or :both
    field :locked_at,               :type => Time
    
    field :authentication_token,    :type => String
    field :invitation_token,        :type => String
    field :invitation_sent_at,      :type => Time
    field :invitation_accepted_at,  :type => Time
    field :invitation_limit,        :type => Integer, :default => 0
    field :invited_by_id,           :type => String
    field :invited_by_type,         :type => String

    # omniauth fields
    field :provider
    field :uid

  end

end