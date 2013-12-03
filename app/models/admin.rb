class Admin
  include Mongoid::Document
  include Mongoid::Timestamps

  devise :database_authenticatable, :recoverable, :trackable, :validatable, :timeoutable, :timeout_in => 30.minutes

  field :email,                     type: String #, null: false
  field :encrypted_password,        type: String #, null: false
  field :reset_password_token,      type: String
  field :reset_password_sent_at,    type: Time
  field :remember_created_at,       type: Time
  field :sign_in_count,             type: Integer
  field :current_sign_in_at,        type: Time
  field :last_sign_in_at,           type: Time
  field :current_sign_in_ip,        type: String
  field :last_sign_in_ip,           type: String
  field :partner,                   type: String
  field :partner_id,                default: nil
  field :infinitely_administrator,  type: Boolean, default: false
  
  index({email: 1},{unique: true})
  index({reset_password_token: 1})
  index({unlock_token: 1})

  # belongs_to :partner

  def to_s
    email
  end

  def reset_password_instruction!
    Mailer.admin_send_reset_password_instructions(self).deliver
  end

end
