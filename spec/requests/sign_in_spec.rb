include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do |config|

  config.before(:each) do
    FactoryGirl.reload 

    user = FactoryGirl.create(:user)
    user.role = 'admin'
    user.save
  end

  config.after(:each) do
    Warden.test_reset!
  end
end

# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
feature 'User Sign in', :devise, type: :request, js: true do
 
  # Scenario: User cannot sign in if not registered
  #   Given I do not exist as a user
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  scenario 'cannot sign in if not registered' do
    visit new_user_session_path
    expect(current_path).to eq '/users/sign_in'
    sign_in('test@example.com', :'notmypassword')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'can sign in with valid credentials' do
    visit new_user_session_path
    expect(current_path).to eq "/users/sign_in"
    sign_in('test@example.com', :'please123')
    expect(current_path).to eq '/users'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    expect(page).to have_content 'Signed in successfully.'
  end

  # Scenario: User cannot sign in with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'cannot sign in with wrong email' do
    visit new_user_session_path
    sign_in('invalid@example.com', :'please123')
    expect(page).to have_content 'Invalid email or password.'
  end

  # Scenario: User cannot sign in with wrong password
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario 'cannot sign in with wrong password' do
    visit new_user_session_path
    sign_in('test@example.com', :'invalidpass')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

end