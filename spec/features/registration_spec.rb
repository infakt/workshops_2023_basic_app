require 'rails_helper'

describe 'Registration', type: :feature do
  before { visit root_path }

  let(:email) { 'email@example.com' }
  let(:password) { 'password123' }

  it 'registers user' do
    click_link('Sign up')

    within '#new_user' do
      fill_in 'user_email',	with: email
      fill_in 'user_password',	with: password
      fill_in 'user_password_confirmation',	with: password

      click_button 'Sign up'
    end

    expect(page).to have_content('Welcome! You have signed up successfully.')
  end
end
