include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
feature 'Sign in', :devise do

  before(:each) do
    FactoryGirl.reload 
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  # Scenario: User cannot sign in if not registered
  #   Given I do not exist as a user
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  scenario 'user cannot sign in if not registered' do
    sign_in('unknown@example.com', 'please123')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'user can sign in with valid credentials' do
    user = FactoryGirl.create(:user)
    sign_in(user.email, user.password)
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
  end

  # Scenario: User cannot sign in with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'user cannot sign in with wrong email' do
    user = FactoryGirl.create(:user)
    sign_in('invalid@email.com', user.password)
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  # Scenario: User cannot sign in with wrong password
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario 'user cannot sign in with wrong password' do
    user = FactoryGirl.create(:user)
    sign_in(user.email, 'invalidpass')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.invalid', authentication_keys: 'email'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end
end