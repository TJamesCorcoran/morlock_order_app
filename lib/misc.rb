class Misc
  def self.response_to_chrome(ret)
    if ret.is_a?(String)
      ret = ret
    else
      ret = ret.body
    end
    open("/tmp/zzz.html", "w") { |f| f << ret.to_s.encode('UTF-8', {
                                   :invalid => :replace,
                                   :undef => :replace,
                                   :replace => '?'
                                 }) }
    system("google-chrome file:///tmp/zzz.html")
  end
end
