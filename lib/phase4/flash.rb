require 'json'
require 'webrick'

module Phase4
  class Flash
    #similar to session this needs to persist across requests

    def initialize(req)
      @show_count = 2
      #each flash should be shown at least once
      req.cookies.each do |cookie|
        @flash = JSON.parse(cookie.value) if cookie.name == "flash_rails_lite_app"
      end
    end



    def [](key)
      @flash[key]
    end
    #regular flash persists for one request, then we flag to be shown already 

    def []=(key, value)
      @flash[key] = value
    end

    def store_flash(res)
      res.cookies << WEBrick::Cookie.new("flash_rails_lite_app", @flash.to_json)
      #stores the flash inside the cookie, but clear the flash if the show count is 0
      clear_flash if @show_count == 0
    end

    def clear_flash
      @flash = {}
    end

    def decrease_show_count
      @show_count -= 1
    end

  end
end
