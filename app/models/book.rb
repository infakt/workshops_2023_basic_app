class Book < ApplicationRecord
  validates :title, presence: true

  after_destroy_commit -> { broadcast_remove_to :books }

  belongs_to :author
  belongs_to :category
  belongs_to :publisher

  has_many :book_loans, dependent: :destroy
  has_many :book_reservations, dependent: :destroy

  def ongoing_loan
    book_loans.checked_out.last
  end

  def ongoing_reservation
    book_reservations.initialized.last
  end

  def reservation_available_for?(user)
    book_loans.checked_out.where.not(user:).any? && book_reservations.initialized.none?
  end

  def loan_available_for?(user)
    book_loans.checked_out.none? && book_reservations.initialized.where.not(user:).none?
  end

  def status_for(user)
    return 'available' if available?

    [loan_status(user), reservation_status(user)].compact_blank.join('; ')
  end

  private

  def available?
    book_loans.checked_out.none? && book_reservations.initialized.none?
  end

  def loan_status(user)
    return '' if ongoing_loan.blank?
    return "loaned (due date: #{ongoing_loan.due_date})" unless ongoing_loan.by_user?(user)

    "loaned (due date: #{ongoing_loan.due_date}) by you"
  end

  def reservation_status(user)
    return '' if ongoing_reservation.blank?

    "reserved#{' by you' if ongoing_reservation.by_user?(user)}"
  end
end
