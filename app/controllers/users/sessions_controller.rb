class Users::SessionsController < Devise::SessionsController
  before_action :load_log_data, only: :destroy

  after_action :sign_out_log, only: :destroy
  after_action :sign_in_log, only: :create

  def sign_out_log
      require 'pry'; binding.pry
    # PUSH
  end

  def sign_in_log

    current_user
      require 'pry'; binding.pry
    # PUSH
  end

  def load_log_data
      require 'pry'; binding.pry
  #   @load_log_data = {
  #     user_id: @user.id,
  #     user_email: @user.email,
  #     published_at: ::Time.zone.now
  #   }
  end
end
