class PrintLabels


  def self.do_it

    # for each pledge tier
    #
    [
      { :name => "$250 level",     :csv => "/home/tjic/personal/writing/ari/fulfillment/250_signed_hc.csv" },
    ].each do |hh|

      puts "==== #{hh[:name]}"

      ii = 0
      
      CSV.foreach(hh[:csv]) do |row|
        # skip header row
        ii += 1
        next if (ii == 1)

        ﻿backer_number           = row[0]

        shipping_name           = row[16]
        shipping_address_1      = row[17]
        shipping_address_2      = row[18]
        shipping_city           = row[19]
        shipping_state          = row[20]
        shipping_postal_code    = row[21]
        shipping_country_name   = row[22]
        shipping_country_code   = row[23]
        shipping_phone_number   = row[24]
        shipping_delivery_notes = row[25]
        email_2                 = row[26]


        str= shipping_name + "\n" +
             shipping_address_1 + "\n" +
             (shipping_address_2.nil? ? ( shipping_address_1 + "\n"  )  : "") +
             shipping_city + ", " + shipping_state + "  " + shipping_postal_code

        puts str
        puts "\n\n\n"
      end # CSV
    end # each
  end
end
