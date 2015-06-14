class UserMailer < ActionMailer::Base
  default from: "do-not-reply@example.com"

  def expire_email(user)
    mail(to: user.email, subject: "Subscription Cancelled")
  end
=begin

  # new to rails-stripe-membership-saas : requires webhooks to be in place, which are not yet in place
  def thanks_email(user)
    mail(to: user.email, subject: "Thank You for your green energy support")
  end

  def transfer_created_email(user)
    member = user.id
    owner = User.first
    mail(to: owner.email, subject: "transfer.created event from Stripe for Member ID \##{member}")
  end

  def plan_changed_email(user)
    mail(to: user.email, subject: "Your Membership Plan at Sequencers has been changed ..")
  end
=end
end