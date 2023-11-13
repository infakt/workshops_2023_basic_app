# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
user1 = ::User.find_or_initialize_by(email: 'user1@test.pl')
user1.update(password: '123User!', password_confirmation: '123User!')

user2 = ::User.find_or_initialize_by(email: 'user2@test.pl')
user2.update(password: '123User!', password_confirmation: '123User!')

10.times { Category.create(name: Faker::Book.genre) }
10.times { Publisher.create(name: Faker::Book.publisher) }
10.times { Author.create(name: Faker::Book.author.split(' ').first, surname: Faker::Book.author.split(' ').last) }

25.times do
  Book.create(
    title: Faker::Book.title,
    isbn: Faker::Code.isbn,
    year: Faker::Number.between(from: 1900, to: 2021),
    page_count: Faker::Number.between(from: 10, to: 1000),
    published_on: Faker::Date.between(from: 100.years.ago, to: Time.zone.today),
    language: 'PL',
    author_id: Author.all.sample.id,
    category_id: Category.all.sample.id,
    publisher_id: Publisher.all.sample.id
  )
end

user1.book_loans.find_or_initialize_by(book: Book.first).update(due_date: Time.zone.today + 2.weeks)
user1.book_loans.find_or_initialize_by(book: Book.second).update(due_date: Time.zone.today + 1.week)

user2.book_loans.find_or_initialize_by(book: Book.third).update(due_date: Time.zone.today + 2.weeks)
user2.book_loans.find_or_initialize_by(book: Book.fourth).update(due_date: Time.zone.today + 1.week)

user1.book_reservations.find_or_create_by(book: user2.book_loans.sample.book)
user2.book_reservations.find_or_create_by(book: user1.book_loans.sample.book)
