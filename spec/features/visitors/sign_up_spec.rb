require 'pry'
require 'stripe_mock'
include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

RSpec.feature 'User Sign in', :devise do
  before(:each) do
    FactoryGirl.reload
    user = FactoryGirl.create(:user)
    user.role = 'admin'
    user.save!
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'cannot sign in if not registered' do
    sign_in('testing@example.com', 'please122')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  scenario 'can sign in with valid credentials' do
    sign_in('test@example.com', 'please123')
    expect(current_path).to eq '/users'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'cannot sign in with wrong email' do
    sign_in('invalid@example.com', 'please123')
    expect(page).to have_content 'Invalid email or password.'
  end

  scenario 'cannot sign in with wrong password' do
    sign_in('test@example.com', 'invalidpass')
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end
end

# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
RSpec.feature 'Sign Up', :devise, type: :features, js: true, live: true do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    CreatePlanService.new.call
    FactoryGirl.reload
    user = FactoryGirl.build(:user, email: 'test@example.com')
    # user.save!
  end

  after(:each) do
    Warden.test_reset!
  end

  scenario 'visitor can sign up as a silver subscriber' do
    plan = Stripe::Plan.retrieve('silver')
    expect(plan.amount).to eq 900
    expect(plan.name).to eq 'Silver'

    token = stripe_helper.generate_card_token(card_number: '4242424242424242')
    customer = Stripe::Customer.create({
      email: 'johnny@appleseed.com',
      source: token
    })
    expect(customer.subscriptions.data).to be_empty
    expect(customer.subscriptions.count).to eq(0)
    expect(token).to match(/^tok_/)

    subscription = customer.subscriptions.create(
      plan: 'silver',
      metadata: { foo: 'bar', example: 'yes' }
    )
    subscription.metadata['foo'] = 'bar'
    expect(subscription.object).to eq('subscription')
    expect(subscription.plan.to_hash).to eq(plan.to_hash)
    expect(subscription.metadata.foo).to eq('bar')
    expect(subscription.metadata.example).to eq('yes')

    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.subscriptions.data).to_not be_empty
    expect(customer.subscriptions.count).to eq(1)
    expect(customer.subscriptions.data.length).to eq(1)
    expect(customer.subscriptions.data.first.id).to eq(subscription.id)
    expect(customer.subscriptions.data.first.plan.to_hash).to eq(plan.to_hash)
    expect(customer.subscriptions.data.first.customer).to eq(customer.id)
    expect(customer.subscriptions.data.first.metadata.foo).to eq 'bar'
    expect(customer.subscriptions.data.first.metadata.example).to eq 'yes'
    expect(customer.email).to eq('johnny@appleseed.com')
    expect(customer.subscriptions.first.plan.id).to eq('silver')
    expect(customer.subscriptions.first.metadata['foo']).to eq('bar')

    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('user4@example.com', 'please124', 'please124')
    expect(page).to have_content 'Welcome! You have signed up successfully.'

    visit '/content/silver'
    expect(current_path).to eq '/content/silver'
  end

  scenario 'visitor can sign up as a gold subscriber' do
    plan = Stripe::Plan.retrieve('gold')
    visit '/users/sign_up?plan=gold'
    expect(current_path).to eq '/users/sign_up'
    sign_up_gold('user5@example.com', 'please125', 'please125')
    expect(page).to have_content 'Welcome! You have signed up successfully.'

    visit '/content/gold'
    expect(current_path).to eq '/content/gold'
  end

  scenario 'visitor can sign up as a platinum subscriber' do
    plan = Stripe::Plan.retrieve('platinum')
    visit '/users/sign_up?plan=platinum'
    expect(current_path).to eq '/users/sign_up'
    sign_up_platinum('user6@example.com', 'please126', 'please126')
    expect(page).to have_content 'Welcome! You have signed up successfully.'
    expect(current_path).to eq '/content/platinum'

    visit '/content/platinum'
    expect(current_path).to eq '/content/platinum'
  end

  # Scenario: Visitor cannot sign up with invalid email address
  #   Given I am not signed in
  #   When I sign up with an invalid email address
  #   Then I see an invalid email message
  scenario 'visitor cannot sign up with invalid email address' do
    plan = Stripe::Plan.retrieve('silver')
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('', 'please126', 'please126')
    # expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '1 error prohibited this user from being saved:'
    expect(page).to have_content "Email can't be blank"
    expect(page).to have_content 'Credit card acceptance is pending.'
  end

  # Scenario: Visitor cannot sign up without password
  #   Given I am not signed in
  #   When I sign up without a password
  #   Then I see a missing password message
  scenario 'visitor cannot sign up without password' do
    plan = Stripe::Plan.retrieve('silver')
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('nopassword@example.com', '', 'please126')
    expect(current_path).to eq '/users/sign_up'
    # expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '2 errors prohibited this user from being saved:'
    expect(page).to have_content "Password can't be blank"
    expect(page).to have_content "Password confirmation doesn't match"
    expect(page).to have_content 'Credit card acceptance is pending.'
  end

  # Scenario: Visitor cannot sign up with a short password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  scenario 'visitor cannot sign up with a short password' do
    plan = Stripe::Plan.retrieve('gold')
    visit '/users/sign_up?plan=gold'
    expect(current_path).to eq '/users/sign_up'
    sign_up_gold('shortpassword@example.com', 'pleas', 'pleas123')
    # expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '3 errors prohibited this user from being saved:'
    expect(page).to have_content 'Password is too short'
    expect(page).to have_content "Password confirmation doesn't match Password"
    expect(page).to have_content 'Credit card acceptance is pending.'
  end

  # Scenario: Visitor cannot sign up without password confirmation
  #   Given I am not signed in
  #   When I sign up without a password confirmation
  #   Then I see a missing password confirmation message
  scenario 'visitor cannot sign up without password confirmation' do
    plan = Stripe::Plan.retrieve('silver')
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('shortpassword@example.com', 'please123', '')
    # expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '1 error prohibited this user from being saved:'
    expect(page).to have_content "Password confirmation doesn't match Password"
    expect(page).to have_content 'Credit card acceptance is pending.'
  end

  # Scenario: Visitor cannot sign up with mismatched password and confirmation
  # Given I am not signed in
  # When I sign up with a mismatched password confirmation
  # Then I should see a mismatched password message
  scenario 'visitor cannot sign up with mismatched password and confirmation' do
    plan = Stripe::Plan.retrieve('silver')
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver('shortpassword@example.com', 'please123', 'please120')
    # expect(page).to have_content 'Please review the problems below:'
    # expect(page).to have_content '1 error prohibited this user from being saved:'
    expect(page).to have_content "Password confirmation doesn't match Password"
    expect(page).to have_content 'Credit card acceptance is pending.'
    expect(page).to have_content 'Password confirmation doesn\'t match'
  end

  # scenario 'visitor cannot sign up with invalid payment information' do
  #  pending 'needs work ? dealt with in spec/stripe ?'
  # end
end
