require 'rails_helper'

describe 'Loan a book', type: :feature do
  let(:user) { create(:user) }
  let!(:book) { create(:book) }

  before do
    login_as(user)
    allow(DueDateNotificationJob).to receive(:perform_at).and_return(true)
  end

  it 'can log in when is registered' do 
    visit root_path
    click_button "Loan"
    expect(page).to have_content('Book Loan was successfully created.')
  end
end