module Features
  module SessionHelpers
    def sign_up(email, password, confirmation)
      visit new_user_registration_path
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      click_button 'Sign up'
    end

    def sign_in(email, password)
      visit new_user_session_path
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      click_button 'Sign in'
    end

    def sign_up_silver(email, password, confirmation)
      visit '/users/sign_up?plan=silver'
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      fill_in :card_number, with: '4242424242424242'
      fill_in :card_code, with: '123'
      select 10, from: :date_month
      select 2020, from: :date_year
      click_button 'Sign up'
    end

    def sign_up_gold(email, password, confirmation)
      visit '/users/sign_up?plan=gold'
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      fill_in :card_number, with: '4242424242424242'
      fill_in :card_code, with: '123'
      select 11, from: :date_month
      select 2021, from: :date_year
      click_button 'Sign up'
    end

    def sign_up_platinum(email, password, confirmation)
      visit '/users/sign_up?plan=platinum'
      fill_in :user_email, with: email
      fill_in :user_password, with: password
      fill_in :user_password_confirmation, with: confirmation
      fill_in :card_number, with: '4242424242424242'
      fill_in :card_code, with: '123'
      select 12, from: :date_month
      select 2022, from: :date_year
      click_button 'Sign up'
    end
  end
end
