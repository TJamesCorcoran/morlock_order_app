class PlaceOrders

  TEAM_TRADE = "http://www.lulu.com/shop/travis-j-i-corcoran/the-team-trade/paperback/product-23262537.html"

  B1_TRADE   = "http://www.lulu.com/shop/travis-j-i-corcoran/book-1-trade/paperback/product-23262534.html"
  B2_TRADE   = "http://www.lulu.com/shop/travis-j-i-corcoran/book-2-trade/paperback/product-23262518.html"

  B1_HARD  = "http://www.lulu.com/shop/travis-j-i-corcoran/book-1-hardcover/hardcover/product-23262551.html"
  B2_HARD  = "http://www.lulu.com/shop/travis-j-i-corcoran/book-2-hardcover/hardcover/product-23262547.html"

  def self.error_check(ret)
    if ! ret[:success]
      puts "*** #{ret[:error_msg]}"
      Misc.response_to_chrome(ret[:body])
      sleep(100)
    end
  end
  
  def self.do_it

    # knobs
    #

    use_coupon = false
    
    LuluRemote.login do

      [ # { :name => "one trade",  :csv => "/home/tjic/personal/writing/ari/fulfillment/20_trade_one.csv", :products => [ B1_TRADE ] },
        # { :name => "two trades", :csv => "/home/tjic/personal/writing/ari/fulfillment/40_trade_two.csv", :products => [ B1_TRADE, B2_TRADE ] },
        # { :name => "two HC", :csv => "/home/tjic/personal/writing/ari/fulfillment/100_hc.csv", :products => [ B1_HARD, B2_HARD ] },
        # { :name => "extreme extras", :csv => "/home/tjic/personal/writing/ari/fulfillment/999_extreme.csv", :products => [ B1_HARD, B2_HARD, B1_TRADE, B2_TRADE ] }

        # { :name => "two trades missing", :csv => "/home/tjic/personal/writing/ari/fulfillment/UNSHIPPED_40_trade_two.csv", :products => [ B1_TRADE, B2_TRADE ] },

        { :name => "one trade hack", :csv => "/home/tjic/personal/writing/ari/fulfillment/HACK_1_trade.csv", :products => [ B1_TRADE ] },
        
      ].each do |hh|

        puts "========== #{hh[:name]}"

        ii = 0
        backer_number           = nil
        backer_uid              = nil
        backer_name             = nil
        email                   = nil
        shipping_country        = nil
        shipping_amount         = nil
        reward_title            = nil
        reward_minimum          = nil
        reward_id               = nil
        pledge_amount           = nil
        pledged_at              = nil
        rewards_sent            = nil
        pledged_status          = nil
        notes                   = nil
        survey_response         = nil
        shipping_name           = nil
        shipping_address_1      = nil
        shipping_address_2      = nil
        shipping_city           = nil
        shipping_state          = nil
        shipping_postal_code    = nil
        shipping_country_name   = nil
        shipping_country_code   = nil
        shipping_phone_number   = nil
        shipping_delivery_notes = nil
        email                   = nil
        explanation             = nil

        CSV.foreach(hh[:csv]) do |row|
          # skip first line, which is a header
          ii += 1
          next if ii == 1

          # puts "row = #{row.class} // #{row.inspect}"
          ﻿backer_number           = row[0]
          backer_uid              = row[1]
          backer_name             = row[2]
          email                   = row[3]
          shipping_country        = row[4]
          shipping_amount         = row[5]
          reward_title            = row[6]
          reward_minimum          = row[7]
          reward_id               = row[8]
          pledge_amount           = row[9]
          pledged_at              = row[10]
          rewards_sent            = row[11]
          pledged_status          = row[12]
          notes                   = row[13]
          survey_response         = row[14]
          shipping_name           = row[15]
          shipping_address_1      = row[16]
          shipping_address_2      = row[17]
          shipping_city           = row[18]
          shipping_state          = row[19]
          shipping_postal_code    = row[20]
          shipping_country_name   = row[21]
          shipping_country_code   = row[22]
          shipping_phone_number   = row[23]
          shipping_delivery_notes = row[24]
          email_2                 = row[25]
          explanation             = row[26]

          puts " * #{backer_number} : #{shipping_name} , #{shipping_address_1}, #{shipping_address_2}, #{shipping_city}, #{shipping_state}, #{shipping_postal_code}" # NOTFORCHECKIN

          if shipping_name.nil? || shipping_name.empty?
            puts "XXX backer number #{backer_number} // #{email} has no shipping addr"
            next
          end
          
          ret = LuluRemote.empty_cart
          error_check(ret)

          hh[:products].each do |product_url|
            ret = LuluRemote.add_book_to_cart(product_url)
            error_check(ret)
          end

          if use_coupon
            ret = LuluRemote.add_coupon("LULU15")
            error_check(ret)
          end
          
          ret = LuluRemote.start_checkout
          error_check(ret)

          ret = LuluRemote.add_address(shipping_name, shipping_address_1, shipping_address_2, shipping_city, shipping_state, shipping_postal_code, "603 529 3462", shipping_country_code)
          error_check(ret)

#          unless shipping_country_code == "AU"
            ret = LuluRemote.choose_shipping_option
            puts "ret = #{ret.inspect}" # NOTFORCHECKIN
            error_check(ret)
#          end
          
          ret = LuluRemote.billing("621")
          error_check(ret)
          
          ret = LuluRemote.review
          error_check(ret)

          puts "order = #{ret[:order_num]} ; price = #{ ret[:total_price].to_currency}"
          
        end
      end
    end
  end
end
