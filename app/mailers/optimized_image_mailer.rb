class OptimizedImageMailer < ApplicationMailer
  def send_notification
    @name = "Elan Kvitko"

    mail to: "imaging@bullionexchanges.com",
         subject: "New Optimized Images - Take Action!"
  end
end
