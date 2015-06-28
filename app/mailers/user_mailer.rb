class UserMailer < ActionMailer::Base
  default from: "do-not-reply@example.com"

  def expire_email(user)
    member = user.id
    owner = User.first
    mail(to: owner.email, subject: "Subscription Cancelled notice sent for Member ID \##{member}")
    mail(to: user.email, subject: "Subscription Cancelled")
  end

  def thanks_email(user)
    member = user.id
    owner = User.first
    mail(to: owner.email, subject: "Thank You sent for green energy support from Stripe for Member ID \##{member}")
    mail(to: user.email, subject: "Thank You for your green energy support")
  end

  def transfer_created_email(user)
    member = user.id
    owner = User.first
    mail(to: owner.email, subject: "transfer.created event from Stripe for Member ID \##{member}")
  end

  def plan_changed_email(user)
    member = user.id
    owner = User.first
    mail(to: owner.email, subject: "A Members Membership Plan at Sequencers has been changed for Member ID \##{member}")
    mail(to: user.email, subject: "Your Membership Plan at Sequencers has been changed ..")
  end
end