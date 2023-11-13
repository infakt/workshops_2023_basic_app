require 'rails_helper'

describe 'Log in', type: :feature do
  let(:user) { create(:user) }

  before do
    visit new_user_session_path
  end

  context 'when user is registered' do
    let(:email) { user.email }
    let(:password) { user.password }

    it 'can log in when is registered' do 
      within '#new_user' do
        fill_in 'user_email', with: email
        fill_in 'user_password', with: password
        click_button 'Log in'
      end

      expect(page).to have_content('Signed in successfully.')
    end
  end
end
