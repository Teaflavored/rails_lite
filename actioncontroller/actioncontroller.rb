require_relative 'flash.rb'
require_relative 'session.rb'
require_relative 'router.rb'
require_relative 'params.rb'

require 'active_support/core_ext'
require 'erb'

class ControllerBase
  attr_reader :req, :res
  attr_reader :params

  # Setup the controller

  def initialize(req, res, route_params = {} )
    @params = Params.new(req, route_params)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response == true
  end

  # Set the response status code and header
  def redirect_to(url)
    raise if already_built_response?
    session.store_session(@res)
    flash.store_flash(@res)
    @res.status = 302
    @res.header["location"] = url 
    @already_built_response = true
  end 

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render(template_name)
    session.store_session(@res)
    template = File.read("views/#{self.class.to_s.underscore}/#{template_name.to_s}.html.erb")
    erb_template = ERB.new(template)
    flash.store_flash(@res)
    render_content(erb_template.result(binding), type="text/html")
  end

  def invoke_action(name)
    self.send(name)
    render name unless already_built_response?
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
      #flash is grabbed from the cookie, we use it inside controller action by calling
      #flash[:errors] = "blah", this should set @flash hash inside our flash object
      #then we store the flash into the cookie
  end

  private

    def render_content(content, type)
      raise if already_built_response?
      @res.body = content
      @res.content_type = type
      @already_built_response = true
      req.cookies.length.times { req.cookies.pop }
    end
end





