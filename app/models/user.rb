class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, 
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :book_loans, dependent: :destroy
  has_many :book_reservations, dependent: :destroy

  def self.from_omniauth(access_token)
    user = User.where(provider: access_token.provider, uid:
      access_token.uid).first_or_create do |user|
      user.provider = access_token.provider
      user.uid = access_token.uid
      user.email = access_token.info.email
      user.password = Devise.friendly_token[0,20]
      user.token = access_token.credentials.token
      user.refresh_token = access_token.credentials.refresh_token
      user.save
    end

    unless user
      user = User.create(
       email: access_token.info.email,
       password: Devise.friendly_token[0,20]
      )
    end
    user
  end
end
