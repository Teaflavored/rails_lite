require_relative '../phase2/controller_base'
require_relative '../phase4/flash.rb'
require 'active_support/core_ext'
require 'erb'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content

    def render(template_name)
    	template = File.read("views/#{self.class.to_s.underscore}/#{template_name.to_s}.html.erb")
    	erb_template = ERB.new(template)

    	render_content(erb_template.result(binding), type="text/html")
    end
  end
end
