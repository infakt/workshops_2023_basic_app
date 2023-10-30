require 'rails_helper'

describe 'Loan book', type: :feature do
  let(:user) { create(:user) }
  let!(:book) { create(:book) }

  before do
    login_as(user)
    visit root_path
  end

  context 'when book is not loaned' do
    it 'loans book' do
      click_button('Loan')

      expect(page).to have_content('Book Loan was successfully created.')
    end
  end

  context 'when book is already loaned' do
    let(:loan) { BookLoan.create(book: book, user: user, due_date: Time.zone.today + 14.days) }

    before { loan } # upewniam się, ze wypozyczenie jest utworzone

    it 'appears in my loans section' do
      click_link('My Loans&Reservations')

      expect(page).to have_content(book.title)
    end
  end
end
