class Flash

  def initialize(req)
    @flash_contains = false
    @flash = {}

    
    #by default flash has shown in it
    #each flash should be shown at least once
    # flash_cookie = req.cookies.find{|c| c.name = "flash_rails_lite_app"}
    req.cookies.each do |cookie|
      @flash = JSON.parse(cookie.value) if cookie.name == "flash_rails_lite_app"
    end
    @flash_contains = true if @flash.keys.length > 0
  end

  def [](key)
    # @flash[key]
    @flash[key]
  end
  #regular flash persists for one request, then we flag to be shown already 

  def []=(key, value)
    # @flash[key] = value
    @flash[key] = value
  end


  def store_flash(res)
    cookie = WEBrick::Cookie.new("flash_rails_lite_app", @flash.to_json)
    cookie.path = "/"
    cookie.value = {}.to_json if @flash_contains
    res.cookies << cookie
    #stores the flash inside the cookie, but clear the flash if the show count is 0
  end

end
