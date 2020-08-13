class ApprovalMailer < ApplicationMailer

	def approval_user(user)
    #@user = user.email_id
    #mail to: manoj.rajendran@altiussolution.com, subject: 'Sample Email'
    
    @user = user
    mail from: "sales@yantra24x7.com"
  # mail to: @user,:subject => 'Confirmation mail from Yantra24x7 '
    mail to: "marimanohar.mahendran@adcltech.com,manisankar.gnanasekaran@adcltech.com", subject: 'Confirmation mail from Yantra24x7'

  end
end
