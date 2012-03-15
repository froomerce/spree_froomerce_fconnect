module Api_calls
  
  def make_api_call(query, relative_url, is_varifi, email)
    return -1 unless query
    if is_dummy?(email)
      url = URI.parse(FroomerceConfig::VERIFICATION[:temp_base]+relative_url)
    else
      url = URI.parse(FroomerceConfig::VERIFICATION[:base]+relative_url)
    end
    
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url.path + "?secret_token=#{FroomerceConfig::VERIFICATION[:token]}&#{query}")
    if is_varifi == 1 then http.use_ssl = (url.scheme == 'https') end
    if is_varifi == 2
      response, status = Net::HTTP.post_form(url ,query)
    else
      response = http.start {|http| http.request(request) }
      status = http.request(request).body
    end
    case response
      when Net::HTTPSuccess then
      result = JSON.parse(status)
      return result
    else
      return -1
    end
  end
  
  def is_dummy?(email)
    if email.eql? 'dummy.export@servis.pk'
      return true
    else
      return false
    end
  end
  
end