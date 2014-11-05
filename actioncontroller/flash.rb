require 'json'
require 'webrick'

class Flash
  attr_reader :show_count
  #similar to session this needs to persist across requests

  def initialize(req)
    @flash = { "shown" => false }
    #by default flash has shown in it
    #each flash should be shown at least once
    req.cookies.each do |cookie|
      @flash = JSON.parse(cookie.value) if cookie.name == "flash_rails_lite_app"
    end
    @flash = {} if @flash["shown"]
  end

  def [](key)
    @flash[key]
  end
  #regular flash persists for one request, then we flag to be shown already 

  def []=(key, value)
    @flash[key] = value
    @flash["shown"] = true
  end

  def store_flash(res)
    res.cookies.delete_if { |name| name == "flash_rails_lite_app" }
    res.cookies << WEBrick::Cookie.new("flash_rails_lite_app", @flash.to_json) unless @flash["shown"] == false
    #stores the flash inside the cookie, but clear the flash if the show count is 0
  end

  def decrease_show_count
    @show_count -= 1
  end

end
