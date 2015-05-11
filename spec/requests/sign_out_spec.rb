# Feature: Sign out
#   As a user
#   I want to sign out
#   So I can protect my account from unauthorized access
feature 'User Sign out', :devise, type: :request do

  # Scenario: User signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  scenario 'signs out successfully' do
    user = User.find_by_email("test@example.com")
    user.delete
    user = FactoryGirl.create(:user)
    user.role = 'admin'
    user.save
    sign_in('test@example.com', 'please123')
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    click_link 'Sign out'
    expect(page).to have_content I18n.t 'devise.sessions.signed_out'
  end

end