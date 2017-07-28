class MorlockMailer < ApplicationMailer
  default from: 'ebooks@morlockpublishing.com'
 
  def epub_mail(email, fingerprint, volume_numbers,
                send_epub,
                send_mobi,
                send_pdf )
    @email          = email
    @fingerprint    = fingerprint
    @volume_numbers = volume_numbers

    @send_epub      = send_epub
    @send_mobi      = send_mobi
    @send_pdf       = send_pdf
    
    mail(to:       @email,
         subject:  "Powers of the Earth kickstarter - your e-books are ready",
         reply_to: "null@example.com")
  end
end
