require 'json'
require 'webrick'

module Phase4
  class Flash
    attr_reader :show_count
    #similar to session this needs to persist across requests

    def initialize(req)
      @flash = { "count" => 2 }
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
      return if @flash["count"].nil?
      @flash["count"] -= 1
      @flash = {} if @flash["count"] == 0
      res.cookies << WEBrick::Cookie.new("flash_rails_lite_app", @flash.to_json)
      #stores the flash inside the cookie, but clear the flash if the show count is 0
    end

    def decrease_show_count
      @show_count -= 1
    end

  end
end
