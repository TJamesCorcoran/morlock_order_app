class SendEpubs


  TRACKING_FILE_EPUB = "/home/tjic/personal/writing/ari/fulfillment/epub_tracking.csv"
  TRACKING_FILE_MOBI = "/home/tjic/personal/writing/ari/fulfillment/mobi_tracking.csv"
  TRACKING_FILE_PDF = "/home/tjic/personal/writing/ari/fulfillment/pdf_tracking.csv"
  
  SEND_EPUB          = true
  SEND_MOBI          = true
  SEND_PDF           = true
  OUTPUT_DIR         = "/home/tjic/personal/writing/ari/fulfillment/generated_epubs/"
  WORK_DIR           = "/home/tjic/personal/writing/ari/fulfillment/generated_epubs/work/"
  SRC_DIR            = "/home/tjic/personal/writing/ari/output_formatted"

  VOL_MAP = { 0 => "book_0_formatted_epub.odt",
              1 => "book_1_formatted_epub.odt",
              2 => "book_2_formatted_epub.odt" }

  TITLE_MAP = { 0 => "The Team",
              1 => "The Powers of the Earth",
              2 => "Causes of Separation" }

  TAGS = { 0 => "0x123",
           1 => "0x13",
           2 => "0x44d5ae4"
         }
  
  def self.do_it

    # config flags
    #
    verbose = false

    
    already_sent_epub = CSV.read(TRACKING_FILE_EPUB).select { |row| row[1] }.map { |row| row[0] }
    already_sent_mobi = CSV.read(TRACKING_FILE_MOBI).select { |row| row[1] }.map { |row| row[0] }
    already_sent_pdf  = CSV.read(TRACKING_FILE_PDF).select  { |row| row[1] }.map { |row| row[0] }

    # for each pledge tier
    #
    [
      # { :name => "ebook - one",    :csv => "/home/tjic/personal/writing/ari/fulfillment/6_ebook_one.csv",  :src => [   1    ] },
      # { :name => "ebook - two",    :csv => "/home/tjic/personal/writing/ari/fulfillment/12_ebook_two.csv", :src => [   1, 2 ] },
      # { :name => "trade - one",    :csv => "/home/tjic/personal/writing/ari/fulfillment/20_trade_one.csv", :src => [   1    ] },
      # { :name => "trade - two",    :csv => "/home/tjic/personal/writing/ari/fulfillment/40_trade_two.csv", :src => [   1, 2 ] },
      # { :name => "HC    - two",    :csv => "/home/tjic/personal/writing/ari/fulfillment/100_hc.csv",       :src => [   1, 2 ] },
      # { :name => "extreme extras", :csv => "/home/tjic/personal/writing/ari/fulfillment/999_extreme.csv",  :src => [0, 1, 2 ] }
      { :name => "fake", :csv => "/home/tjic/personal/writing/ari/fulfillment/fake.csv",  :src => [0 ] }
    ].each do |hh|

      puts "==== #{hh[:name]}"

      ii = 0
      CSV.foreach(hh[:csv]) do |row|
        # skip header row
        ii += 1
        next if ii == 1



        email = row[3]
        next if email.nil?
        fingerprint = "0x" + Digest::SHA256.hexdigest(email)[0,7]

        cust_needs_epub = SEND_EPUB && ! already_sent_epub.include?(email)
        cust_needs_mobi = SEND_MOBI && ! already_sent_mobi.include?(email)
        cust_needs_pdf  = SEND_PDF  && ! already_sent_pdf.include?(email)

        if ! cust_needs_epub && ! cust_needs_mobi && ! cust_needs_pdf
          puts "  * SKIPPING - #{email}"
          next
        end
        
        puts "  * #{fingerprint} - #{email} - epub: #{cust_needs_epub} / mobi: #{cust_needs_mobi} / pdf: #{cust_needs_pdf}"
        before_time = Time.now


        volume_numbers = hh[:src]
        volume_numbers.each do |vol|
          puts "  vol #{vol}" if verbose
          # setup vars
          #
          vol_name = VOL_MAP[vol]
          fake_tag = TAGS[vol]

          puts "     . chdir 1" if verbose
          Dir.chdir(OUTPUT_DIR)
          puts "     . rmdir" if verbose
          `rm -rf #{WORK_DIR}`
          puts "     . mkdirs" if verbose
          `mkdir -p #{WORK_DIR}`
          puts "     . chdir 2" if verbose
          Dir.chdir(WORK_DIR)

          
          # move to directory, get input, expand
          #

          input_filename = VOL_MAP[vol]
          puts "     . cp" if verbose
          `cp #{SRC_DIR}/#{input_filename} .`
          puts "     . unzip" if verbose
          `unzip #{input_filename}`

          # make edit
          #
          puts "     . sed" if verbose
          `sed -i s/#{fake_tag}/#{fingerprint}/g content.xml`

          
          # rebuild odt - see https://crcok.wordpress.com/2014/10/25/unzip-and-zip-openoffice-org-odt-files/
          #
          intermediate_base = "aristillus_#{vol}_#{fingerprint}"
          intermediate_odt  = "#{intermediate_base}.odt"

          output_epub       = "#{intermediate_base}.epub"
          output_mobi       = "#{intermediate_base}.mobi"
          output_pdf        = "#{intermediate_base}.pdf"
          
          puts "     . make odt" if verbose
          `rm -rf  Configurations2/toolpanel/ Configurations2/floater/ Configurations2/menubar/ Configurations2/toolbar/ Configurations2/progressbar/ Configurations2/statusbar/ Configurations2/popupmenu/ Configurations2/images/Bitmaps/`
          `zip -0 -X #{intermediate_odt} mimetype`
          `zip -r #{intermediate_odt} * -x mimetype -x #{intermediate_odt} -x #{input_filename} -x Configurations2` 

          # generate PDF, mobi, epub
          title = TITLE_MAP[vol]
          common_flags = "--title '#{title}' --authors 'Travis J. I. Corcoran' --language 'English' --pubdate '20 July 2017' --publisher 'Morlock Publishing' --series 'Aristillus' --series-index '#{vol}' --tags 'AI, anarchocapitalism, antigravity, corporate finance, economics, genetically modified dogs, guns, lunar colonization, open source software, revolution, social media'"
          if cust_needs_epub

            epub_flags = ""
            convert_str =  "ebook-convert #{intermediate_odt} #{output_epub} #{common_flags} #{epub_flags}"
            puts "     . make epub: #{convert_str}" if verbose
            `#{convert_str}`
            `mv #{output_epub} ..`
          end

          if cust_needs_mobi
            puts "     . make mobi" if verbose
            mobi_flags = ""
            convert_str =  "ebook-convert #{intermediate_odt} #{output_mobi} #{common_flags} #{epub_flags}"
            puts "     . make mobi: #{convert_str}" if verbose
            `#{convert_str}`

            `mv #{output_mobi} ..`            
          end

          if cust_needs_pdf
            puts "     . make pdf" if verbose
            pdf_flags = " --margin-bottom 72 --margin-left 72 --margin-top 72 --margin-right 72"
            convert_str =  "ebook-convert #{intermediate_odt} #{output_pdf} #{common_flags} #{epub_flags}"
            puts "     . make pdf: #{convert_str}" if verbose
            `#{convert_str}`

            `mv #{output_pdf} ..`                        
          end


          if SEND_EPUB || SEND_MOBI || SEND_PDF
            puts "     . scp" if verbose
            Dir.chdir(OUTPUT_DIR)
            
            filelist = []
            filelist << output_epub if cust_needs_epub
            filelist << output_mobi if cust_needs_mobi
            filelist << output_pdf  if cust_needs_pdf
            filelist = filelist.join(" " )

            `scp -p -P 7822 -i ~/#{ENV[SSH_KEY_LOCATION]} #{filelist} #{ENV[EPUB_LOCATION]}`
          end
          
          
          
        end
        puts "     . email" if verbose

        ActionMailer::Base.logger = nil
        MorlockMailer.epub_mail(email, fingerprint, volume_numbers,
                                cust_needs_epub,
                                cust_needs_mobi,
                                cust_needs_pdf).deliver_now

        puts "     . tracking file" if verbose

        open(TRACKING_FILE_EPUB, "a") { |f| f << "#{email}, #{fingerprint}, #{Time.now}" } if cust_needs_epub
        open(TRACKING_FILE_MOBI, "a") { |f| f << "#{email}, #{fingerprint}, #{Time.now}" } if cust_needs_mobi
        open(TRACKING_FILE_PDF, "a")  { |f| f << "#{email}, #{fingerprint}, #{Time.now}" } if cust_needs_pdf

        puts "     ....DONE #{ (Time.now() - before_time).to_i } seconds"
        
      end
    end # each
  end
end

 
