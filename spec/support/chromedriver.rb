require 'selenium/webdriver'

Capybara.app_host = 'http://localhost:3010' # wybieramy port na którym capybara będzie uruchamiała przeglądarkę
Capybara.server_host = 'localhost'
Capybara.server_port = '3010' # wybieramy port

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.configure do |config|
  config.javascript_driver = :chrome
  config.default_driver = :chrome
end
