require_relative '../phase3/controller_base'
require_relative './session'

module Phase4
  class ControllerBase < Phase3::ControllerBase
    def redirect_to(url)
    	flash.decrease_show_count
    	#a request is made, there should be 1 count left
    	#when second request is made there'll be 0 counts left and flash will clear
    	session.store_session(@res)
    	flash.store_flash(@res)

    	super
    end

    def render_content(content, type)
    	flash.decrease_show_count
    	session.store_session(@res)
    	flash.store_flash(@res)

    	super
    end

    # method exposing a `Session` object
    def session
    	@session ||= Session.new(@req)
    end

    def flash
    	@flash ||= Flash.new(@req)
    	#flash is grabbed from the cookie, we use it inside controller action by calling
    	#flash[:errors] = "blah", this should set @flash hash inside our flash object
    	#then we store the flash into the cookie
    end
  end
end
